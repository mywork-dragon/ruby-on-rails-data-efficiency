#!/bin/sh

IP=$( curl http://169.254.169.254/latest/meta-data/private-ipv4 )
HOST_SUFFIX='ms-internal.com'
HOST="$ECS_SERVICE_NAME.$HOST_SUFFIX"
HOSTED_ZONE_ID='Z3QMLWJ9T4W065'
echo "Registering $HOST as $IP"


INPUT_JSON="{
  \"Comment\": \"Update the A record set\",
  \"Changes\": [
    {
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$HOST\",
        \"Type\": \"A\",
        \"TTL\": 5,
        \"ResourceRecords\": [
          {
            \"Value\": \"$IP\"
          }
        ]
      }
    }
  ]
}"

INPUT_JSON="{ \"ChangeBatch\": $INPUT_JSON }"

aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --cli-input-json "$INPUT_JSON"

bundle exec unicorn_rails -c config/unicorn.rb
