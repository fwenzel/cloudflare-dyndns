#!/bin/sh

CFAPI_ENDPOINT='https://api.cloudflare.com/client/v4'
IPIFY_ENDPOINT='https://api.ipify.org'

log() {
    TIMESTAMP=$(date +'%Y-%m-%d %H:%:%S')
    echo "[${TIMESTAMP}] $1"
}

. .env.production
if [ "$CFAPI_TOKEN" = "" ]; then
    log "Error: Environment variables not set."
    exit 1
fi

oldip=$(dig +short "$HOST" | tail -n1)
newip=$(curl -s "$IPIFY_ENDPOINT")

if [ "$oldip" = "$newip" ]; then
    log "IP $oldip unchanged."
    exit 0
fi

zoneid=$(curl -sX GET "$CFAPI_ENDPOINT/zones?name=$ZONE" \
     -H "Authorization: Bearer $CFAPI_TOKEN" \
     | jq -r '.result[0] .id')

recordid=$(curl -sX GET "$CFAPI_ENDPOINT/zones/$zoneid/dns_records?name=$HOST" \
     -H "Authorization: Bearer $CFAPI_TOKEN" \
     | jq -r '.result[0] .id')

success=$(curl -sX PATCH "$CFAPI_ENDPOINT/zones/$zoneid/dns_records/$recordid" \
     -H "Authorization: Bearer $CFAPI_TOKEN" \
     --data "{\"content\":\"$newip\"}" \
     | jq -r '.success')
if [ "$success" = 'true' ]; then
    log "IP updated from $oldip to $newip."
    exit 0
else
    log "Error updating IP from $oldip to $newip :o"
    exit 1
fi
