export const local = {
  endpoint: process.env.TF_VAR_endpoint_url, // LocalStack endpoint
  region: process.env.TF_VAR_aws_region,
  credentials: {
    accessKeyId: process.env.TF_VAR_aws_access_key_id, // default LocalStack creds
    secretAccessKey: process.env.TF_VAR_aws_secret_access_key,
  },
};
