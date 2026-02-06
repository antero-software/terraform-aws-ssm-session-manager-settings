output "s3_bucket_name" {
  description = "Name of the S3 bucket for session logs"
  value       = aws_s3_bucket.session_logs.id
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for session logs"
  value       = aws_cloudwatch_log_group.session_logs.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key for session encryption"
  value       = aws_kms_key.session_logs.arn
}
