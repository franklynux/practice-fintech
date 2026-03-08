variable "name_prefix" {
  description = "Prefix used for naming PostgreSQL and pgBouncer resources."
  type        = string
  default     = "fintech"
}

variable "vpc_id" {
  description = "VPC ID where PostgreSQL and pgBouncer will run."
  type        = string
}

variable "db_subnet_ids" {
  description = "Private database subnet IDs for the RDS subnet group."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Private application subnet IDs for pgBouncer instances and internal NLB."
  type        = list(string)
}

variable "allowed_client_cidrs" {
  description = "CIDRs allowed to connect to pgBouncer on PostgreSQL port."
  type        = list(string)
  default     = []
}

variable "additional_db_ingress_cidrs" {
  description = "Optional CIDRs allowed direct access to PostgreSQL."
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "transactions"
}

variable "db_master_username" {
  description = "Master username for PostgreSQL."
  type        = string
  default     = "txn_admin"
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "15.10"
}

variable "parameter_group_family" {
  description = "Parameter group family matching the engine major version."
  type        = string
  default     = "postgres15"
}

variable "instance_class" {
  description = "Primary PostgreSQL instance class."
  type        = string
  default     = "db.m6g.large"
}

variable "read_replica_instance_class" {
  description = "Read replica instance class."
  type        = string
  default     = "db.m6g.large"
}

variable "allocated_storage" {
  description = "Initial storage size in GiB."
  type        = number
  default     = 100
}

variable "max_allocated_storage" {
  description = "Maximum storage autoscaling size in GiB."
  type        = number
  default     = 500
}

variable "max_connections" {
  description = "PostgreSQL max_connections parameter."
  type        = string
  default     = "1000"
}

variable "backup_retention_days" {
  description = "Automated backup retention in days (enables PITR when > 0)."
  type        = number
  default     = 14
}

variable "backup_window" {
  description = "Preferred daily backup window in UTC."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred weekly maintenance window in UTC."
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection for primary DB instance."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot if the DB instance is destroyed."
  type        = bool
  default     = true
}

variable "create_read_replica" {
  description = "Create same-region read replica and lag alarm."
  type        = bool
  default     = true
}

variable "replica_lag_threshold_seconds" {
  description = "CloudWatch alarm threshold for replica lag in seconds."
  type        = number
  default     = 1
}

variable "pgbouncer_instance_type" {
  description = "EC2 instance type for pgBouncer nodes."
  type        = string
  default     = "t3.micro"
}

variable "pgbouncer_desired_capacity" {
  description = "Desired number of pgBouncer instances."
  type        = number
  default     = 2
}

variable "pgbouncer_min_size" {
  description = "Minimum number of pgBouncer instances."
  type        = number
  default     = 2
}

variable "pgbouncer_max_size" {
  description = "Maximum number of pgBouncer instances."
  type        = number
  default     = 4
}

variable "pgbouncer_max_client_conn" {
  description = "Maximum client connections accepted by pgBouncer."
  type        = number
  default     = 5000
}

variable "pgbouncer_default_pool_size" {
  description = "Default server pool size in pgBouncer."
  type        = number
  default     = 80
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
