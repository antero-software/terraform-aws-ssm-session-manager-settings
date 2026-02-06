# terraform-aws-ssm-session-manager-settings

Secure AWS SSM Session Manager configuration (Logging, Encryption, & Compliance) via Terraform.

This Terraform module configures AWS Systems Manager Session Manager with comprehensive logging and encryption settings.

## Features

- **KMS Encryption**: Customer-managed KMS key with automatic key rotation enabled
- **CloudWatch Logging**: Centralized logging with 30-day retention policy
- **S3 Storage**: Secure S3 bucket for session logs with:
  - Versioning enabled
  - Public access blocked
  - SSE-S3 encryption
  - Automatic expiration after 365 days
- **Session Manager Document**: Pre-configured SSM document for secure session management

## Usage

```hcl
module "ssm_session_manager" {
  source = "github.com/antero-software/terraform-aws-ssm-session-manager-settings"

  name_prefix = "my-company"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| name_prefix | Prefix to use for naming resources | `string` | yes |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_name | Name of the S3 bucket for session logs |
| cloudwatch_log_group_arn | ARN of the CloudWatch Log Group for session logs |
| kms_key_arn | ARN of the KMS key for session encryption |

## Resources Created

This module creates the following AWS resources:

1. **KMS Key** (`aws_kms_key.session_logs`) - Customer-managed key with rotation enabled
2. **KMS Alias** (`aws_kms_alias.session_logs`) - Alias for the KMS key
3. **CloudWatch Log Group** (`aws_cloudwatch_log_group.session_logs`) - Log group with 30-day retention
4. **S3 Bucket** (`aws_s3_bucket.session_logs`) - Bucket for session log storage
5. **S3 Bucket Versioning** (`aws_s3_bucket_versioning.session_logs`) - Versioning configuration
6. **S3 Bucket Encryption** (`aws_s3_bucket_server_side_encryption_configuration.session_logs`) - SSE-S3 encryption
7. **S3 Public Access Block** (`aws_s3_bucket_public_access_block.session_logs`) - Blocks all public access
8. **S3 Lifecycle Configuration** (`aws_s3_bucket_lifecycle_configuration.session_logs`) - 365-day expiration rule
9. **SSM Document** (`aws_ssm_document.session_manager_prefs`) - Session Manager configuration document

## License

Apache 2.0 Licensed. See LICENSE for full details.
