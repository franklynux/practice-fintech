output "selected_availability_zones" {
  value       = local.selected_azs
  description = "List of selected AZs"
}

output "vpc_id" {
  value       = aws_vpc.eu-west-2-vpc.id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = aws_vpc.eu-west-2-vpc.cidr_block
  description = "Primary CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnets[*].id
  description = "List of Public Subnet IDs"
}

output "app_private_subnet_ids" {
  value       = aws_subnet.app_private_subnets[*].id
  description = "List of Private Subnet IDs"
}

output "database_subnet_ids" {
  value       = aws_subnet.database_subnets[*].id
  description = "List of Database Subnet IDs"
}

output "cde_subnet_ids" {
  value       = aws_subnet.cde_subnets[*].id
  description = "List of CDE Subnet IDs"
}

output "app_private_route_table_ids" {
  value       = aws_route_table.app_private_route_table[*].id
  description = "Route table IDs for applications' private subnets"
}



