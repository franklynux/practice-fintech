output "kms_key_arn" {
  description = "KMS key ARN used for PostgreSQL encryption at rest."
  value       = aws_kms_key.postgres.arn
}

output "db_security_group_id" {
  description = "Security group ID attached to PostgreSQL."
  value       = aws_security_group.postgres.id
}

output "pgbouncer_security_group_id" {
  description = "Security group ID attached to pgBouncer nodes."
  value       = aws_security_group.pgbouncer.id
}

output "primary_db_instance_id" {
  description = "Primary PostgreSQL DB instance identifier."
  value       = aws_db_instance.primary.id
}

output "postgres_primary_db_instance_arn" {
  description = "Primary PostgreSQL DB instance ARN."
  value       = aws_db_instance.primary.arn
}

output "primary_db_endpoint" {
  description = "Primary PostgreSQL endpoint."
  value       = aws_db_instance.primary.address
}

output "primary_db_port" {
  description = "Primary PostgreSQL port."
  value       = aws_db_instance.primary.port
}

output "read_replica_db_instance_id" {
  description = "Read replica identifier (if enabled)."
  value       = try(aws_db_instance.read_replica[0].id, null)
}

output "read_replica_db_endpoint" {
  description = "Read replica endpoint (if enabled)."
  value       = try(aws_db_instance.read_replica[0].address, null)
}

output "replica_lag_alarm_name" {
  description = "CloudWatch alarm name for replica lag target."
  value       = try(aws_cloudwatch_metric_alarm.replica_lag_too_high[0].alarm_name, null)
}

output "pgbouncer_endpoint" {
  description = "Internal NLB DNS endpoint for pgBouncer."
  value       = aws_lb.pgbouncer.dns_name
}

output "pgbouncer_port" {
  description = "Port exposed by pgBouncer."
  value       = var.db_port
}
