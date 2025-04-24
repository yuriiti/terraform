import { LambdaClient } from '@aws-sdk/client-lambda';

export const handler = async (event: any) => {
  const client = new LambdaClient({
    region: process.env.TF_VAR_aws_region,
  });

  console.log('Invoking Lambda function...');
  console.log('Event:', event, process.env.TF_VAR_aws_region);
};
