import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { local } from './config';

const snsClient = new SNSClient(local);

describe('LocalStack SNS', () => {
  it('should publish a message to SNS', async () => {
    const command = new PublishCommand({
      TopicArn: `arn:aws:sns:${process.env.TF_VAR_aws_region}:000000000000:incoming-messages`,
      Message: JSON.stringify({ target: 'ping', message: 'ping-pong' }),
      MessageAttributes: {
        target: {
          DataType: 'String',
          StringValue: 'ping',
        },
      },
    });

    const response = await snsClient.send(command);

    expect(response).toBeDefined();
    expect(response.MessageId).toBeDefined();
  });
});
