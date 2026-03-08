output "selected_availability_zones" {
  value       = module.vpc.selected_availability_zones
  description = "List of selected AZs"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "Primary CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "List of Public Subnet IDs"
}

output "app_private_subnet_ids" {
  value       = module.vpc.app_private_subnet_ids
  description = "List of Private Subnet IDs"
}

output "database_subnet_ids" {
  value       = module.vpc.database_subnet_ids
  description = "List of Database Subnet IDs"
}

output "cde_subnet_ids" {
  value       = module.vpc.cde_subnet_ids
  description = "List of CDE Subnet IDs"
}

output "app_private_route_table_ids" {
  value       = module.vpc.app_private_route_table_ids
  description = "Route table IDs for applications' private subnets"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint"
}

output "eks_node_group_name" {
  value       = module.eks.node_group_name
  description = "Primary EKS node group name"
}

output "eks_cluster_oidc_issuer" {
  value       = module.eks.cluster_oidc_issuer
  description = "OIDC issuer URL for IRSA"
}

# output "postgres_cross_region_replica_db_endpoint" {
#   value       = module.postgres_replica.replica_endpoint
#   description = "Cross-region PostgreSQL replica endpoint."
# }

# output "postgres_cross_region_replica_db_instance_arn" {
#   value       = module.postgres_replica.replica_instance_arn
#   description = "Cross-region PostgreSQL replica ARN."
# }

# output "postgres_replica_db_lag_alarm_name" {
#   value       = module.postgres_replica.replica_lag_alarm_name
#   description = "CloudWatch alarm tracking 1-second replica lag objective."
# }

# output "postgres_replica_db_kms_key_arn" {
#   value       = module.postgres_replica.kms_key_arn
#   description = "KMS key ARN used for replica encryption."
# }
