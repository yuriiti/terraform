// Создание SNS топика для входящих сообщений
resource "aws_sns_topic" "incoming" {
  name = "incoming-messages"
}

// Создание SNS подписки для API Gateway
data "aws_iam_policy_document" "apigw_publish" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.incoming.arn]
  }
}

// Создание IAM роли для API Gateway
// Эта роль позволяет API Gateway публиковать сообщения в SNS
resource "aws_iam_role" "apigw_sns_role" {
  name               = "apigw-sns-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

// Создание IAM политики для API Gateway
resource "aws_iam_role_policy" "apigw_publish" {
  name = "apigw-sns-publish"
  role = aws_iam_role.apigw_sns_role.id
  policy = data.aws_iam_policy_document.apigw_publish.json
}

resource "aws_api_gateway_integration" "post_messages_sns" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.post_messages.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:sns:path//"      # fixed SNS URI
  credentials = aws_iam_role.apigw_sns_role.arn

  request_templates = {
    # map incoming body = message, plus optional JSON attr 'target'
    "application/json" = <<EOF
Action=Publish&
TopicArn=${aws_sns_topic.incoming.arn}&
Message=$util.urlEncode($input.body)&
MessageAttributes.entry.1.Name=target&
MessageAttributes.entry.1.Value.DataType=String&
MessageAttributes.entry.1.Value.StringValue=$util.urlEncode($input.path('$.target'))
EOF
  }

  # 200 OK passthrough
  passthrough_behavior = "WHEN_NO_MATCH"
}