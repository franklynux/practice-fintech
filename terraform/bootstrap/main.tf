
# S3 Bucket With State-Locking Enabled for Remote State Backend provisioned in US-East-1 region ( Single Source Of Truth)
resource "aws_s3_bucket" "statefile-us-east-1" {
  bucket              = "${var.bucket_name}-us-east-1"
  force_destroy       = false
  object_lock_enabled = true

  tags = {
    Name = "Xterns-N-Virginia-Remote-Statefile-Storage"
  }
}

# Enable versioning for S3 bucket
resource "aws_s3_bucket_versioning" "statefile-us-east-1" {
  bucket = aws_s3_bucket.statefile-us-east-1.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable object lock in governance mode for compliance (Prevents accidental deletion of S3 bucket)
resource "aws_s3_bucket_object_lock_configuration" "statefile-us-east-1" {
  bucket     = aws_s3_bucket.statefile-us-east-1.id
  depends_on = [aws_s3_bucket_versioning.statefile-us-east-1]

  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.statefile_object_lock_retention_days
    }
  }
}

# Public access block
resource "aws_s3_bucket_public_access_block" "statefile-us-east-1" {
  bucket = aws_s3_bucket.statefile-us-east-1.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create KMS key for encrypting S3 bucket in US East (N. Virginia)
resource "aws_kms_key" "s3_bucket_key-us-east-1" {
  description             = "KMS key for S3 remote state bucket (us-east-1)"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name = "Xterns-N.Virginia-S3-Bucket-KMS-Key"
  }
}

# Attach KMS encryption to S3 bucket in US East with bucket key enabled for cost optimization (N. Virginia)
resource "aws_s3_bucket_server_side_encryption_configuration" "statefile-us-east-1" {
  bucket = aws_s3_bucket.statefile-us-east-1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_bucket_key-us-east-1.arn
    }
    bucket_key_enabled = true
  }
}


