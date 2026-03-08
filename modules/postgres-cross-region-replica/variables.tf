variable "name_prefix" {
  description = "Prefix used for naming cross-region replica resources."
  type        = string
  default     = "fintech"
}

variable "vpc_id" {
  description = "VPC ID where the replica will run."
  type        = string
}

variable "db_subnet_ids" {
  description = "Private database subnet IDs for the replica subnet group."
  type        = list(string)
}

variable "source_db_arn" {
  description = "ARN of the source PostgreSQL DB instance in primary region."
  type        = string
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "instance_class" {
  description = "Replica DB instance class."
  type        = string
  default     = "db.m6g.large"
}

variable "multi_az" {
  description = "Whether to run the read replica in Multi-AZ mode."
  type        = bool
  default     = true
}

variable "parameter_group_family" {
  description = "Parameter group family matching the source engine major version."
  type        = string
  default     = "postgres15"
}

variable "max_connections" {
  description = "PostgreSQL max_connections parameter."
  type        = string
  default     = "1000"
}

variable "backup_retention_days" {
  description = "Automated backup retention in days."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window in UTC."
  type        = string
  default     = "02:00-03:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window in UTC."
  type        = string
  default     = "sun:03:00-sun:04:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection on the replica."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot if replica is destroyed."
  type        = bool
  default     = true
}

variable "replica_lag_threshold_seconds" {
  description = "CloudWatch alarm threshold for replica lag in seconds."
  type        = number
  default     = 1
}

variable "allowed_client_cidrs" {
  description = "CIDRs allowed to connect directly to the replica."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
