import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { local } from './config';
import {
  DeleteMessageCommand,
  GetQueueUrlCommand,
  ReceiveMessageCommand,
  SQSClient,
} from '@aws-sdk/client-sqs';

const snsClient = new SNSClient(local);
const sqsClient = new SQSClient(local);

const SPECIFIC_MESSAGE = 'hello world';

describe('LocalStack SQS', () => {
  it('should send a message to SQS', async () => {
    const command = new PublishCommand({
      TopicArn: `arn:aws:sns:${process.env.TF_VAR_aws_region}:000000000000:incoming-messages`,
      Message: JSON.stringify({ target: 'test', message: SPECIFIC_MESSAGE }),
      MessageAttributes: {
        target: {
          DataType: 'String',
          StringValue: 'test',
        },
      },
    });
    const response = await snsClient.send(command);

    expect(response).toBeDefined();
    expect(response.MessageId).toBeDefined();
  });

  it('should receive a message from SQS', async () => {
    const getQueueUrlCommand = new GetQueueUrlCommand({
      QueueName: 'sns-test-queue',
    });
    const { QueueUrl } = await sqsClient.send(getQueueUrlCommand);

    expect(QueueUrl).toBeDefined();

    const receiveMessageCommand = new ReceiveMessageCommand({
      QueueUrl: QueueUrl,
      MaxNumberOfMessages: 10,
      WaitTimeSeconds: 10,
    });
    const receiveMessageResponse = await sqsClient.send(receiveMessageCommand);

    expect(receiveMessageResponse).toBeDefined();

    const messages: string[] = [];

    for (const message of receiveMessageResponse.Messages || []) {
      const command = new DeleteMessageCommand({
        QueueUrl: QueueUrl,
        ReceiptHandle: message.ReceiptHandle,
      });

      await sqsClient.send(command);

      const body = JSON.parse(message.Body || '{}');

      expect(body).toBeDefined();
      expect(body.message).toBeDefined();

      messages.push(body.message);
    }

    expect(messages).toContain(SPECIFIC_MESSAGE);
  });
});
