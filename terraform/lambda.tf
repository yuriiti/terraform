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

resource "aws_lambda_function" "send_to_s3_lambda" {
  function_name    = "send-to-s3-lambda"
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