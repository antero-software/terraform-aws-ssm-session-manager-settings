terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ssm_session_manager" {
  source = "../../"

  name_prefix = "example"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for session logs"
  value       = module.ssm_session_manager.s3_bucket_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for session logs"
  value       = module.ssm_session_manager.cloudwatch_log_group_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key for session encryption"
  value       = module.ssm_session_manager.kms_key_arn
}
