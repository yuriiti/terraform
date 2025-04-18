import {
  APIGatewayClient,
  GetResourcesCommand,
  GetRestApisCommand,
  TestInvokeMethodCommand,
} from '@aws-sdk/client-api-gateway';
import { local } from './config';

const apigateway = new APIGatewayClient(local);

describe('LocalStack API Gateway', () => {
  let apiId: string;

  test('created API should be listed', async () => {
    const command = new GetRestApisCommand();
    const data = await apigateway.send(command);

    expect(data).toBeDefined();
    expect(data.items).toBeDefined();

    const api = data.items?.find((item) => item.name === 'signed-endpoint');

    expect(api).toBeDefined();

    apiId = api?.id || '';
  });

  test('API should have a valid ID', () => {
    expect(apiId).toBeDefined();
    expect(apiId).not.toBe('');
  });

  test('signed-endpoint "messages" invocation returns status 200', async () => {
    // получаем список ресурсов API
    const resources = await apigateway.send(
      new GetResourcesCommand({ restApiId: apiId }),
    );

    const resource = resources.items?.find((item) => item.path === '/messages');

    expect(resource).toBeDefined();

    // выполняем тестовый invoke
    const command = new TestInvokeMethodCommand({
      restApiId: apiId,
      resourceId: resource!.id!,
      httpMethod: 'POST',
      pathWithQueryString: resource?.path,
      body: JSON.stringify({
        target: 'test',
        message: 'test',
      }),
      headers: {
        'x-api-key': process.env.TF_VAR_api_key,
      },
    });

    const invokeResult = await apigateway.send(command);

    expect(invokeResult.status).toBe(200);
  });
});
