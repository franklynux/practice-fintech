locals {
  enable_map = var.enabled ? { enabled = true } : {}

  base_tags = merge(
    {
      ManagedBy = "terraform"
      Module    = "vpc-peering"
    },
    var.tags
  )

  # Route-table targets (from VPC stack outputs), tightened to sets
  us_east_1_route_table_ids = var.enabled ? toset(var.us_east_1_private_route_table_ids) : toset([])
  eu_west_1_route_table_ids = var.enabled ? toset(var.eu_west_1_private_route_table_ids) : toset([])
  eu_west_2_route_table_ids = var.enabled ? toset(var.eu_west_2_private_route_table_ids) : toset([])

  # CIDRs (from VPC stack outputs)
  us_east_1_cidr_block = var.us_east_1_vpc_cidr
  eu_west_1_cidr_block = var.eu_west_1_vpc_cidr
  eu_west_2_cidr_block = var.eu_west_2_vpc_cidr
}