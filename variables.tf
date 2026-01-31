variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Default name for S3 buckets"
  type        = string
  default     = "xterns-s3-statefile"
}

