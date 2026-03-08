terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  base_name = "${var.name_prefix}-postgres-replica"
  common_tags = merge(
    {
      ManagedBy = "terraform"
      Component = "postgres-cross-region-replica"
    },
    var.tags
  )
}

# Create KMS key for Replica DB
resource "aws_kms_key" "replica" {
  description             = "KMS key for ${local.base_name} encryption at rest"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.common_tags
}

resource "aws_kms_alias" "replica" {
  name          = "alias/${local.base_name}"
  target_key_id = aws_kms_key.replica.id
}

# Create subnet group for Replica DB
resource "aws_db_subnet_group" "replica" {
  name       = "${local.base_name}-subnets"
  subnet_ids = var.db_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-subnets"
    }
  )
}

# Create Security group for Replica + configure ingress/egress rules
resource "aws_security_group" "replica" {
  name        = "${local.base_name}-sg"
  description = "restrict replica access to approved clients."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-sg"
    }
  )
}

# Allow inbound traffic from Client CIDRs 
resource "aws_vpc_security_group_ingress_rule" "replica_from_clients" {
  for_each          = toset(var.allowed_client_cidrs)
  security_group_id = aws_security_group.replica.id
  description       = "allows client traffic to cross-region replica."
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

# Allows egress traffic out
resource "aws_vpc_security_group_egress_rule" "replica_to_any" {
  security_group_id = aws_security_group.replica.id
  description       = "allows egress for engine-managed operations."
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Create Parameter group for Replica DB (e.g Max connections)
resource "aws_db_parameter_group" "replica" {
  name        = "${local.base_name}-params"
  family      = var.parameter_group_family
  description = "Performance tuning for ${local.base_name}."

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  tags = local.common_tags
}

# Create and configure Replica DB instance
resource "aws_db_instance" "replica" {
  identifier          = "${local.base_name}-instance"
  replicate_source_db = var.source_db_arn
  instance_class      = var.instance_class
  multi_az            = var.multi_az

  db_subnet_group_name   = aws_db_subnet_group.replica.name
  vpc_security_group_ids = [aws_security_group.replica.id]
  parameter_group_name   = aws_db_parameter_group.replica.name
  port                   = var.db_port

  storage_encrypted = true
  kms_key_id        = aws_kms_key.replica.arn

  backup_retention_period    = var.backup_retention_days
  backup_window              = var.backup_window
  maintenance_window         = var.maintenance_window
  copy_tags_to_snapshot      = true
  delete_automated_backups   = false
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  auto_minor_version_upgrade = true
  publicly_accessible        = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-instance"
      Role = "cross-region-replica"
    }
  )
}

# Create Cloudwatch alarm to be triggered on lag > 1s
resource "aws_cloudwatch_metric_alarm" "replica_lag_too_high" {
  alarm_name          = "lag-over-${var.replica_lag_threshold_seconds}s"
  alarm_description   = "Replica lag above ${var.replica_lag_threshold_seconds}s for ${local.base_name}."
  namespace           = "AWS/RDS"
  metric_name         = "ReplicaLag"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 1
  threshold           = var.replica_lag_threshold_seconds
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.replica.id
  }

  tags = local.common_tags
}
