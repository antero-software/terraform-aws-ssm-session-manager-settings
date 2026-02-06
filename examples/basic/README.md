# Example Usage

This directory contains an example of how to use the terraform-aws-ssm-session-manager-settings module.

## Usage

1. Set your AWS credentials:
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Outputs

After applying, you'll see the following outputs:
- `s3_bucket_name` - The name of the S3 bucket created for session logs
- `cloudwatch_log_group_arn` - The ARN of the CloudWatch Log Group
- `kms_key_arn` - The ARN of the KMS key used for encryption

## Cleanup

To destroy the resources:
```bash
terraform destroy
```
