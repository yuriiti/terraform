variable "endpoint_url" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "api_key" {
  type = string
}

output "endpoint" { value = var.endpoint_url }
output "aws_region" { value = var.aws_region }
output "aws_access_key_id" { value = var.aws_access_key_id }
output "aws_secret_access_key" { value = var.aws_secret_access_key }
output "api_key" { value = var.api_key }
