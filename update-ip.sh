#!/bin/bash

CFAPI='https://api.cloudflare.com/client/v4'

. .env.production

oldip=`dig +short $HOST | tail -n1`
echo "old: $oldip"

newip=`curl -s https://api.ipify.org`
echo "new: $newip"

if [ "$oldip" == "$newip" ]; then
    echo "nothing to do here"
    exit 0
fi

zoneid=$(curl -sX GET "$CFAPI/zones?name=$ZONE" \
     -H "Authorization: Bearer ${CFAPI_TOKEN}" \
     | jq -r '.result[0] .id')
#echo $zoneid

recordid=$(curl -sX GET "$CFAPI/zones/$zoneid/dns_records?name=$HOST" \
     -H "Authorization: Bearer ${CFAPI_TOKEN}" \
     | jq -r '.result[0] .id')
#echo $recordid

success=$(curl -sX PATCH "$CFAPI/zones/$zoneid/dns_records/$recordid" \
     -H "Authorization: Bearer ${CFAPI_TOKEN}" \
     --data "{\"content\":\"$newip\"}" \
     | jq -r '.success')
if [ "$success" == 'true' ]; then
    exit 0
else
    exit 1
fi
