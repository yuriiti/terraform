// Создание API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "signed-endpoint"
}

// Создание ресурса для API Gateway (/messages)
resource "aws_api_gateway_resource" "messages" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "messages"
}

// Создание метода POST для ресурса /messages
resource "aws_api_gateway_method" "post_messages" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "POST"
  authorization = "NONE"
  // Включаем подпись для метода (x-api-key)
  api_key_required = true
}

// Создание MOCK интеграции для метода POST
# resource "aws_api_gateway_integration" "post_messages_mock" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.messages.id
#   http_method = aws_api_gateway_method.post_messages.http_method
#   type        = "MOCK"
#   request_templates = {
#     "application/json" = "{\"statusCode\": 200}"
#   }
# }

// Создание ответа для метода POST
resource "aws_api_gateway_method_response" "post_messages_ok" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.post_messages.http_method
  status_code = "200"
}

// Создание интеграционного ответа для метода POST
resource "aws_api_gateway_integration_response" "post_messages_ok" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.post_messages.http_method
  status_code = aws_api_gateway_method_response.post_messages_ok.status_code

  depends_on = [
    aws_api_gateway_integration.post_messages_sns,
  ]
}

// Создание API Gateway Deployment
resource "aws_api_gateway_deployment" "dep" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_method.post_messages.id,
      aws_api_gateway_integration.post_messages_sns.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on  = [aws_api_gateway_integration.post_messages_sns]
}

// Создание stage для API Gateway
resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.dep.id
  stage_name    = "prod"
}

// Создание API Gateway Key
resource "aws_api_gateway_api_key" "client_key" {
  name = "api-client-key"
  value = var.api_key
}

// Создание Usage Plan для API Gateway
// Usage Plan - это способ управления доступом к API Gateway
resource "aws_api_gateway_usage_plan" "plan" {
  name = "signed-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }

  lifecycle {
    ignore_changes = [ api_stages ]
  }
}

// Привязка API Gateway Key к Usage Plan
resource "aws_api_gateway_usage_plan_key" "attach" {
  key_id        = aws_api_gateway_api_key.client_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.plan.id
}