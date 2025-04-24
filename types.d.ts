declare namespace NodeJS {
  interface ProcessEnv {
    NODE_ENV: 'development' | 'production' | 'test';

    LOCALSTACK_HOST: string;
    LOCALSTACK_PORT: string;

    TF_VAR_endpoint_url: string;
    TF_VAR_aws_access_key_id: string;
    TF_VAR_aws_secret_access_key: string;
    TF_VAR_aws_region: string;
    TF_VAR_api_key: string;
  }
}
