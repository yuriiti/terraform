# Создаём тестовую SQS‑очередь
resource "aws_sqs_queue" "test" {
  name = "sns-test-queue"
}

# Подписываем очередь на наш SNS‑топик
resource "aws_sns_topic_subscription" "to_sqs" {
  topic_arn            = aws_sns_topic.incoming.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.test.arn
  raw_message_delivery = true   # получаем “сырое” тело
}