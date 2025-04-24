terraform {
  required_version = ">= 1.11"
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = var.aws_access_key_id
  secret_key                  = var.aws_secret_access_key
  skip_credentials_validation = true          # skip real AWS checks
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    apigateway = var.endpoint_url
    sns        = var.endpoint_url
    sqs        = var.endpoint_url
    lambda     = var.endpoint_url
    s3         = var.endpoint_url
    ses        = var.endpoint_url
    iam        = var.endpoint_url
  }
}
