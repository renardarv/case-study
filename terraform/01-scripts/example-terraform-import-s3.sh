#!/bin/bash

BUCKET_ID=${1}

terraform import module.bucket.aws_s3_bucket.this ${BUCKET_ID}
terraform import module.bucket.aws_s3_bucket_versioning.this ${BUCKET_ID}

if [[ $(cat main.tf | grep block_public_access | awk '{print $3}') == 'true' ]]; then
  terraform import "module.bucket.aws_s3_bucket_public_access_block.this[0]" ${BUCKET_ID}
fi

if [[ $(cat main.tf | grep policy_file | awk '{print $3}') != "" ]]; then
  terraform import "module.bucket.aws_s3_bucket_policy.this[0]" ${BUCKET_ID}
fi

if [[ $(cat main.tf | grep lifecycle_rules | awk '{print $3}') != '[]' ]]; then
  terraform import "module.bucket.aws_s3_bucket_lifecycle_configuration.this[0]" ${BUCKET_ID}
fi

if [[ $(cat main.tf | grep queues | awk '{print $3}') != '[]' ]]; then
  terraform import "module.bucket.aws_s3_bucket_notification.this[0]" ${BUCKET_ID}
fi

if [[ $(cat main.tf | grep cors_rules | awk '{print $3}') != '[]' ]]; then
  terraform import "module.bucket.aws_s3_bucket_cors_configuration.this[0]" ${BUCKET_ID}
fi
