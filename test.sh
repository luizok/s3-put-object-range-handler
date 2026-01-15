#!/bin/bash

INBOUND_BUCKET_NAME=$(jq -r '.inbound_bucket_name.value' outputs.json)
PROCESSED_DATA_BUCKET_NAME=$(jq -r '.processed_data_bucket_name.value' outputs.json)

aws s3 rm s3://$PROCESSED_DATA_BUCKET_NAME --recursive
aws s3 rm s3://$INBOUND_BUCKET_NAME --recursive

for filename in ./tests/*; do
    aws s3 cp $filename s3://$INBOUND_BUCKET_NAME/inbound_data/${filename:2}
done
