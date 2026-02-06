variable "name_prefix" {
  description = "Prefix to use for naming resources"
  type        = string
}

variable "log_group_retention_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group."
  type        = number
  default     = 30
}

variable "s3_lifecycle_expiration_days" {
  description = "Specifies the number of days after which to expire objects in the S3 bucket."
  type        = number
  default     = 365
}

variable "enable_kms" {
  description = "Enable KMS encryption for Session Manager logs."
  type        = bool
  default     = false
}
