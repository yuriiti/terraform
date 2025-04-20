resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

# API for service 'ecr' not yet implemented or pro feature
# resource "aws_ecr_repository" "send_to_s3_repo" {
#   name = "send-to-s3-lambda-repo"
# }

resource "aws_lambda_function" "send_to_s3_lambda" {
  function_name    = "send-to-s3-lambda"
#   package_type  = "Image"
#   image_uri     = "${aws_ecr_repository.send_to_s3_repo.repository_url}:latest"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = "./services/send-to-s3-lambda/send-to-s3-lambda.zip"
  source_code_hash = filebase64sha256("./services/send-to-s3-lambda/send-to-s3-lambda.zip")

  environment {
    variables = {
      TF_VAR_aws_region = var.aws_region
    }
  }

  depends_on = [aws_iam_role.lambda_role]
}

# Привязываем очередь SQS к Lambda функции
resource "aws_lambda_event_source_mapping" "send_to_s3_lambda_trigger" {
  event_source_arn = aws_sqs_queue.sand_to_s3.arn
  function_name    = aws_lambda_function.send_to_s3_lambda.arn
  batch_size       = 1
  enabled          = true

  depends_on = [
    aws_lambda_function.send_to_s3_lambda,
    aws_sqs_queue.sand_to_s3
  ]
}