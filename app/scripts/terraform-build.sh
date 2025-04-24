#!/bin/bash
set -e

cd "$(dirname "$0")/.." || exit 1

docker run --rm \
    --network terraform_localstack_network \
    --env-file .env.local \
    -v "$(pwd)/terraform:/workspace" \
    -v "$(pwd)/services:/workspace/services" \
    -w /workspace \
    --entrypoint /bin/sh \
    hashicorp/terraform:latest \
    -c "terraform init && terraform apply -auto-approve"
