output "peering_connection_ids" {
  description = "VPC peering connection IDs for the full mesh."
  value       = module.vpc_peering.peering_connection_ids
}
