# Создаём очередь для сохранения в S3
resource "aws_sqs_queue" "ping" {
  name = "sns-ping-queue"
}

# Подписываем очередь для сохранения в S3 на SNS-топик
resource "aws_sns_topic_subscription" "ping" {
  topic_arn            = aws_sns_topic.incoming.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.ping.arn
  raw_message_delivery = true

  filter_policy = jsonencode({
    target = ["ping"]
  })
}

# Создаём очередь для сохранения в S3
resource "aws_sqs_queue" "sand_to_s3" {
  name = "sns-sand-to-s3-queue"
}

# Подписываем очередь для сохранения в S3 на SNS-топик
resource "aws_sns_topic_subscription" "to_s3" {
  topic_arn            = aws_sns_topic.incoming.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.sand_to_s3.arn
  raw_message_delivery = true

  filter_policy = jsonencode({
    target = ["sand-to-s3"]
  })
}

# Создаём очередь для отправки email
resource "aws_sqs_queue" "send-email" {
  name = "sns-send-email-queue"
}

# Подписываем очередь для отправки email на наш SNS‑топик
resource "aws_sns_topic_subscription" "to_email" {
  topic_arn            = aws_sns_topic.incoming.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.send-email.arn
  raw_message_delivery = true

  filter_policy = jsonencode({
    target = ["send-email"]
  })
}