#!/bin/bash
set -e

docker exec -it awscli aws logs tail /aws/lambda/send-to-s3-lambda --follow --endpoint-url=http://localstack:4566
