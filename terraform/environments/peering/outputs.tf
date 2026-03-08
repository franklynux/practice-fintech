output "peering_connection_ids" {
  description = "VPC peering connection IDs for the full mesh."
  value       = module.vpc_peering.peering_connection_ids
}

output "cross_region_lb_accelerator_arn" {
  description = "ARN of the Global Accelerator used for cross-region balancing."
  value       = module.cross_region_lb_prep.accelerator_arn
}

output "cross_region_lb_dns_name" {
  description = "DNS name of the Global Accelerator."
  value       = module.cross_region_lb_prep.accelerator_dns_name
}

output "cross_region_lb_listener_arn" {
  description = "Listener ARN of the Global Accelerator."
  value       = module.cross_region_lb_prep.listener_arn
}

output "cross_region_lb_configured_regions" {
  description = "Regions with configured Global Accelerator endpoint groups."
  value       = module.cross_region_lb_prep.configured_endpoint_regions
}
