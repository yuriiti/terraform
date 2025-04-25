#!/bin/sh
set -e

ls -al

nx run s3-lambda:package-local

nodemon \
    --watch ./apps/s3-lambda \
    --ext ts,json \
    --delay 200ms \
    --exec "nx run s3-lambda:package-local"

# "aws --endpoint-url=http://localstack:4566 lambda update-function-code --function-name s3-lambda --zip-file fileb://s3-lambda.zip"
