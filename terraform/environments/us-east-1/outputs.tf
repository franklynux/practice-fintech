output "selected_availability_zones" {
  value       = module.vpc.selected_availability_zones
  description = "List of selected AZs"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
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
