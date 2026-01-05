#!/bin/bash

INBOUND_BUCKET_NAME=$(jq -r '.inbound_bucket.value' outputs.json)
for filename in ./tests/*; do
    aws s3 cp $filename s3://$INBOUND_BUCKET_NAME/inbound_data/${filename:2}
done
