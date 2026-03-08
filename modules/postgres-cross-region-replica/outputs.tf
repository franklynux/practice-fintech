output "replica_kms_key_arn" {
  description = "KMS key ARN used for replica encryption at rest."
  value       = aws_kms_key.replica.arn
}

output "replica_security_group_id" {
  description = "Security group ID attached to replica."
  value       = aws_security_group.replica.id
}

output "replica_db_instance_id" {
  description = "Cross-region replica instance identifier."
  value       = aws_db_instance.replica.id
}

output "replica_db_instance_arn" {
  description = "Cross-region replica instance ARN."
  value       = aws_db_instance.replica.arn
}

output "replica_db_endpoint" {
  description = "Cross-region replica endpoint."
  value       = aws_db_instance.replica.address
}

output "replica_db_lag_alarm_name" {
  description = "CloudWatch alarm name for replica lag objective."
  value       = aws_cloudwatch_metric_alarm.replica_lag_too_high.alarm_name
}
