output "US-bucket_name" {
  value = aws_s3_bucket.statefile-us-east-1.bucket

}

output "US-bucket_id" {
  value = aws_s3_bucket.statefile-us-east-1.id

}

output "kms_master_key_id_us_east_1" {
  value = aws_kms_key.s3_bucket_key-us-east-1.key_id

}
