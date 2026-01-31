variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "xterns-s3-statefile"
}

variable "statefile_object_lock_retention_days" {
  description = "Default object lock retention for the state bucket in governance mode (days)"
  type        = number
  default     = 30
}

variable "kms_deletion_window_in_days" {
  description = "Deletion window in days for the S3 bucket KMS key"
  type        = number
  default     = 30
}

