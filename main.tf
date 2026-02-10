data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "session_logs_kms" {
  count = var.enable_kms ? 1 : 0
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudWatch Logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.name_prefix}-ssm-session-logs"]
    }
  }
}

# KMS Key for Session Manager encryption
resource "aws_kms_key" "session_logs" {
  count                   = var.enable_kms ? 1 : 0
  description             = "${var.name_prefix}-ssm-session-logs"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.name_prefix}-ssm-session-logs"
  }
  policy = data.aws_iam_policy_document.session_logs_kms[0].json
}

resource "aws_kms_alias" "session_logs" {
  count         = var.enable_kms ? 1 : 0
  name          = "alias/${var.name_prefix}-ssm-session-logs"
  target_key_id = aws_kms_key.session_logs[0].key_id
}

# CloudWatch Log Group for Session Manager logs
resource "aws_cloudwatch_log_group" "session_logs" {
  name              = "${var.name_prefix}-ssm-session-logs"
  retention_in_days = var.log_group_retention_days
  kms_key_id        = var.enable_kms ? aws_kms_key.session_logs[0].arn : null

  tags = {
    Name = "${var.name_prefix}-ssm-session-logs"
  }
}

# S3 Bucket for Session Manager logs
resource "aws_s3_bucket" "session_logs" {
  bucket = "${var.name_prefix}-ssm-session-logs"

  tags = {
    Name = "${var.name_prefix}-ssm-session-logs"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "session_logs" {
  bucket = aws_s3_bucket.session_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "session_logs" {
  bucket = aws_s3_bucket.session_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "session_logs" {
  bucket = aws_s3_bucket.session_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Rule
resource "aws_s3_bucket_lifecycle_configuration" "session_logs" {
  bucket = aws_s3_bucket.session_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = var.s3_lifecycle_expiration_days
    }
  }
}

# SSM Document for Session Manager configuration
resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = aws_s3_bucket.session_logs.id
      s3KeyPrefix                 = ""
      s3EncryptionEnabled         = var.enable_kms
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.session_logs.name
      cloudWatchEncryptionEnabled = var.enable_kms
      cloudWatchStreamingEnabled  = false
      kmsKeyId                    = var.enable_kms ? aws_kms_key.session_logs[0].arn : ""
      runAsEnabled                = true
      runAsDefaultUser            = ""
    }
  })

  tags = {
    Name = "${var.name_prefix}-ssm-session-manager"
  }
}
