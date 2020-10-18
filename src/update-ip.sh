#!/bin/sh

CFAPI_ENDPOINT='https://api.cloudflare.com/client/v4'
IPIFY_ENDPOINT='https://api.ipify.org'

. .env.production
if [ "$CFAPI_TOKEN" = "" ]; then
    echo "Error: Environment variables not set."
    exit 1
fi

oldip=$(dig +short "$HOST" | tail -n1)
newip=$(curl -s "$IPIFY_ENDPOINT")

if [ "$oldip" = "$newip" ]; then
    echo "IP $oldip unchanged."
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
    echo "IP updated from $oldip to $newip."
    exit 0
else
    echo "Error updating IP from $oldip to $newip :o"
    exit 1
fi
