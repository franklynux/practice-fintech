output "accelerator_arn" {
  description = "Global Accelerator ARN."
  value       = aws_globalaccelerator_accelerator.this.arn
}

output "accelerator_dns_name" {
  description = "Global Accelerator DNS name."
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "accelerator_hosted_zone_id" {
  description = "Route53 hosted zone ID for alias records."
  value       = aws_globalaccelerator_accelerator.this.hosted_zone_id
}

output "listener_arn" {
  description = "Global Accelerator listener ARN."
  value       = aws_globalaccelerator_listener.this.id
}

output "configured_endpoint_regions" {
  description = "Regions currently wired with endpoint groups."
  value       = keys(aws_globalaccelerator_endpoint_group.regional)
}
