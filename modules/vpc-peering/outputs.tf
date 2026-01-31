output "peering_connection_ids" {
  description = "VPC peering connection IDs for the full mesh."
  value = var.enabled ? {
    us_east_1_to_eu_west_1 = aws_vpc_peering_connection.us_east_1_to_eu_west_1["enabled"].id
    us_east_1_to_eu_west_2 = aws_vpc_peering_connection.us_east_1_to_eu_west_2["enabled"].id
    eu_west_1_to_eu_west_2 = aws_vpc_peering_connection.eu_west_1_to_eu_west_2["enabled"].id
  } : {}
}
