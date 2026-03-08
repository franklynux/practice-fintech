terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_region" "current" {}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  base_name = "${var.name_prefix}-postgres"
  common_tags = merge(
    {
      ManagedBy = "terraform"
      Component = "postgres-primary"
    },
    var.tags
  )
}

# Create KMS resources
resource "aws_kms_key" "postgres" {
  description             = "KMS key for ${local.base_name} encryption at rest"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.common_tags
}

resource "aws_kms_alias" "postgres" {
  name          = "alias/${local.base_name}"
  target_key_id = aws_kms_key.postgres.id
}

# Create DB subnet group
resource "aws_db_subnet_group" "postgres" {
  name       = "${local.base_name}-subnets"
  subnet_ids = var.db_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-subnets"
    }
  )
}

# Create PostgreSQL security group + configure ingress/egress rules
resource "aws_security_group" "postgres" {
  name        = "${local.base_name}-db-sg"
  description = "Restrict PostgreSQL access to approved clients and pgBouncer."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-db-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_pgbouncer" {
  security_group_id            = aws_security_group.postgres.id
  description                  = "PostgreSQL access from pgBouncer."
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.pgbouncer.id
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_direct_cidrs" {
  for_each          = toset(var.additional_db_ingress_cidrs)
  security_group_id = aws_security_group.postgres.id
  description       = "Optional direct PostgreSQL access."
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "postgres_to_anywhere" {
  security_group_id = aws_security_group.postgres.id
  description       = "Allow egress for engine-managed operations."
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Create pgBouncer security group + ingress/egress rules
resource "aws_security_group" "pgbouncer" {
  name        = "${local.base_name}-pgbouncer-sg"
  description = "Client-facing pgBouncer access and DB egress."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-pgbouncer-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "pgbouncer_from_clients" {
  for_each          = toset(var.allowed_client_cidrs)
  security_group_id = aws_security_group.pgbouncer.id
  description       = "Allow client traffic to pgBouncer."
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "pgbouncer_to_postgres" {
  security_group_id            = aws_security_group.pgbouncer.id
  description                  = "Allow pgBouncer to connect to PostgreSQL."
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.postgres.id
}

resource "aws_vpc_security_group_egress_rule" "pgbouncer_to_internet" {
  security_group_id = aws_security_group.pgbouncer.id
  description       = "Allow package/image pulls through NATGW."
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Create DB parameter group
resource "aws_db_parameter_group" "postgres" {
  name        = "${local.base_name}-params"
  family      = var.parameter_group_family
  description = "Performance tuning for ${local.base_name}."

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  tags = local.common_tags
}

# Create Primary RDS PostgreSQL instance
resource "aws_db_instance" "primary" {
  identifier            = "${local.base_name}-primary"
  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.postgres.arn

  db_name                     = var.db_name
  username                    = var.db_master_username
  manage_master_user_password = true
  port                        = var.db_port

  multi_az               = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name

  backup_retention_period    = var.backup_retention_days
  backup_window              = var.backup_window
  maintenance_window         = var.maintenance_window
  copy_tags_to_snapshot      = true
  delete_automated_backups   = false
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  auto_minor_version_upgrade = true

  iam_database_authentication_enabled = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = aws_kms_key.postgres.arn
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-primary"
      Role = "primary"
    }
  )
}

# Create Read Replica in primary region (optional)
# resource "aws_db_instance" "read_replica" {
#   count = var.create_read_replica ? 1 : 0

#   identifier                 = "${local.base_name}-replica"
#   replicate_source_db        = aws_db_instance.primary.identifier
#   instance_class             = var.read_replica_instance_class
#   publicly_accessible        = false
#   db_subnet_group_name       = aws_db_subnet_group.postgres.name
#   vpc_security_group_ids     = [aws_security_group.postgres.id]
#   auto_minor_version_upgrade = true

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${local.base_name}-replica"
#       Role = "read-replica"
#     }
#   )
# }


# # Configure Replica lag alarm (< 1s)
# resource "aws_cloudwatch_metric_alarm" "replica_lag_too_high" {
#   count = var.create_read_replica ? 1 : 0

#   alarm_name          = "${local.base_name}-replica-lag-gt-${var.replica_lag_threshold_seconds}s"
#   alarm_description   = "Replica lag above ${var.replica_lag_threshold_seconds}s for ${local.base_name}."
#   namespace           = "AWS/RDS"
#   metric_name         = "ReplicaLag"
#   statistic           = "Average"
#   period              = 60
#   evaluation_periods  = 1
#   threshold           = var.replica_lag_threshold_seconds
#   comparison_operator = "GreaterThanThreshold"
#   treat_missing_data  = "notBreaching"

#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.read_replica[0].id
#   }

#   tags = local.common_tags
# }


# PG BOUNCER

# Create IAM role for pgbouncer instance (EC2)
resource "aws_iam_role" "pgbouncer" {
  name = "${local.base_name}-pgbouncer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# Attach SSM policy to pgbouncer instance
resource "aws_iam_role_policy_attachment" "pgbouncer_ssm" {
  role       = aws_iam_role.pgbouncer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allow pgbouncer instance access to read secrets from Secrets Manager
resource "aws_iam_role_policy" "pgbouncer_secrets_read" {
  name = "${local.base_name}-pgbouncer-secrets-policy"
  role = aws_iam_role.pgbouncer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_db_instance.primary.master_user_secret[0].secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create Instance Profile for pgbouncer (to be attached to all instances when auto-scaling)
resource "aws_iam_instance_profile" "pgbouncer" {
  name = "${local.base_name}-pgbouncer-profile"
  role = aws_iam_role.pgbouncer.name
}

# Create Launch Template + Auto Scaling Group for pgbouncer
resource "aws_launch_template" "pgbouncer" {
  name_prefix   = "${local.base_name}-pgbouncer-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.pgbouncer_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.pgbouncer.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.pgbouncer.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/pgbouncer-bootstrap.sh.tftpl", {
    secret_arn                  = aws_db_instance.primary.master_user_secret[0].secret_arn
    aws_region                  = data.aws_region.current.name
    db_host                     = aws_db_instance.primary.address
    db_port                     = var.db_port
    db_name                     = var.db_name
    pgbouncer_max_client_conn   = var.pgbouncer_max_client_conn
    pgbouncer_default_pool_size = var.pgbouncer_default_pool_size
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_tags,
      {
        Name = "${local.base_name}-pgbouncer"
      }
    )
  }
}

# Create Auto Scaling Group for pgbouncer
resource "aws_autoscaling_group" "pgbouncer" {
  name                = "${local.base_name}-pgbouncer-asg"
  desired_capacity    = var.pgbouncer_desired_capacity
  min_size            = var.pgbouncer_min_size
  max_size            = var.pgbouncer_max_size
  vpc_zone_identifier = var.app_subnet_ids
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.pgbouncer.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.base_name}-pgbouncer"
    propagate_at_launch = true
  }
}

resource "aws_lb" "pgbouncer" {
  # trucates LB name to 32 characters
  name               = substr("${local.base_name}-pgb", 0, 32)
  internal           = true
  load_balancer_type = "network"
  subnets            = var.app_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${local.base_name}-pgbouncer"
    }
  )
}

resource "aws_lb_target_group" "pgbouncer" {
  name        = substr("${local.base_name}-pgb-tg", 0, 32)
  port        = var.db_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = local.common_tags
}

resource "aws_autoscaling_attachment" "pgbouncer_tg" {
  autoscaling_group_name = aws_autoscaling_group.pgbouncer.id
  lb_target_group_arn    = aws_lb_target_group.pgbouncer.arn
}

resource "aws_lb_listener" "pgbouncer" {
  load_balancer_arn = aws_lb.pgbouncer.arn
  port              = var.db_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pgbouncer.arn
  }
}
