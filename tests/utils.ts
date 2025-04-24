import { PublishCommand, SNSClient } from '@aws-sdk/client-sns';
import {
  DeleteMessageBatchCommand,
  GetQueueUrlCommand,
  ReceiveMessageCommand,
  SQSClient,
} from '@aws-sdk/client-sqs';

/**
 * Отправляет сообщение в SNS и проверяет ответ
 */
export async function publishSNS(
  client: SNSClient,
  target: string,
  message: string,
) {
  const command = new PublishCommand({
    TopicArn: `arn:aws:sns:${process.env.TF_VAR_aws_region}:000000000000:incoming-messages`,
    Message: JSON.stringify({ target, message }),
    MessageAttributes: {
      target: {
        DataType: 'String',
        StringValue: target,
      },
    },
  });

  const response = await client.send(command);

  expect(response).toBeDefined();
  expect(response.MessageId).toBeDefined();

  return response;
}

/**
 * Получает сообщения из SQS и проверяет ответ
 */
export async function receiveMessage(client: SQSClient, queueName: string) {
  const queueUrl = await getQueueUrl(client, queueName);

  const receiveMessageCommand = new ReceiveMessageCommand({
    QueueUrl: queueUrl,
    MaxNumberOfMessages: 10,
    WaitTimeSeconds: 0,
  });
  const receiveMessageResponse = await client.send(receiveMessageCommand);

  expect(receiveMessageResponse).toBeDefined();

  return receiveMessageResponse;
}

/**
 * Удаляет все сообщения из SQS
 */
export async function deleteAllMessages(client: SQSClient, queueName: string) {
  const queueUrl = await getQueueUrl(client, queueName);

  while (true) {
    const receiveResponse = await client.send(
      new ReceiveMessageCommand({
        QueueUrl: queueUrl,
        MaxNumberOfMessages: 10,
        WaitTimeSeconds: 0, // не ждать сообщений
      }),
    );

    if (!receiveResponse.Messages || receiveResponse.Messages.length === 0) {
      break;
    }

    const deleteEntries = receiveResponse.Messages.map((message) => ({
      Id: message.MessageId!, // MessageId обязательный, так как он присутствует когда получаем сообщения
      ReceiptHandle: message.ReceiptHandle!,
    }));

    await client.send(
      new DeleteMessageBatchCommand({
        QueueUrl: queueUrl,
        Entries: deleteEntries,
      }),
    );
  }
}

/**
 * Получает URL очереди SQS по имени
 */
export async function getQueueUrl(client: SQSClient, queueName: string) {
  const { QueueUrl } = await client.send(
    new GetQueueUrlCommand({ QueueName: queueName }),
  );

  expect(QueueUrl).toBeDefined();

  return QueueUrl;
}
