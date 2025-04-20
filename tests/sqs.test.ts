import { SNSClient } from '@aws-sdk/client-sns';
import { local } from './config';
import { SQSClient } from '@aws-sdk/client-sqs';
import { deleteAllMessages, publishSNS, receiveMessage } from './utils';

const snsClient = new SNSClient(local);
const sqsClient = new SQSClient(local);

const SPECIFIC_MESSAGE = 'hello world';

describe('LocalStack SQS', () => {
  afterEach(async () => {
    await deleteAllMessages(sqsClient, 'sns-ping-queue');
    await deleteAllMessages(sqsClient, 'sns-sand-to-s3-queue');
    await deleteAllMessages(sqsClient, 'sns-send-email-queue');
  });

  it('should send a message to SQS', async () => {
    await publishSNS(snsClient, 'ping', SPECIFIC_MESSAGE);
  });

  it('should receive a message from SQS', async () => {
    await publishSNS(snsClient, 'ping', SPECIFIC_MESSAGE);

    const receiveMessageResponse = await receiveMessage(
      sqsClient,
      'sns-ping-queue',
    );

    const messages: string[] = [];

    for (const message of receiveMessageResponse.Messages || []) {
      const body = JSON.parse(message.Body || '{}');

      expect(body).toBeDefined();
      expect(body.message).toBeDefined();

      messages.push(body.message);
    }

    expect(messages).toContain(SPECIFIC_MESSAGE);
  });

  it('should receive messages from different targets', async () => {
    const checkMessages = async (
      saveToS3MustBe: number,
      sandEmailMustBe: number,
    ) => {
      const [receiveSaveToS3MessageResponse, receiveSandEmailMessageResponse] =
        await Promise.all([
          receiveMessage(sqsClient, 'sns-sand-to-s3-queue'),
          receiveMessage(sqsClient, 'sns-send-email-queue'),
        ]);

      expect(receiveSaveToS3MessageResponse).toBeDefined();

      if (saveToS3MustBe > 0) {
        expect(receiveSaveToS3MessageResponse.Messages).toBeDefined();
        expect(receiveSaveToS3MessageResponse.Messages?.length).toBe(
          saveToS3MustBe,
        );
      } else {
        expect(receiveSaveToS3MessageResponse.Messages).toBeUndefined();
      }

      expect(receiveSandEmailMessageResponse).toBeDefined();

      if (sandEmailMustBe > 0) {
        expect(receiveSandEmailMessageResponse.Messages).toBeDefined();
        expect(receiveSandEmailMessageResponse.Messages?.length).toBe(
          sandEmailMustBe,
        );
      } else {
        expect(receiveSandEmailMessageResponse.Messages).toBeUndefined();
      }
    };

    await checkMessages(0, 0);
    await publishSNS(snsClient, 'sand-to-s3', SPECIFIC_MESSAGE);
    await checkMessages(1, 0);
  });
});
