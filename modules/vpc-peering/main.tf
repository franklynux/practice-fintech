terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws.us_east_1,
        aws.eu_west_1,
        aws.eu_west_2,
      ]
    }
  }
}

# Peering connections (same as before)
# US To Ireland ( Requester)

resource "aws_vpc_peering_connection" "us_east_1_to_eu_west_1" {
  for_each    = local.enable_map
  provider    = aws.us_east_1
  vpc_id      = var.us_east_1_vpc_id
  peer_vpc_id = var.eu_west_1_vpc_id
  peer_region = "eu-west-1"
  auto_accept = false

  tags = merge(local.base_tags, { Name = "us-east-1-to-eu-west-1" })
}

# Ireland To US
resource "aws_vpc_peering_connection_accepter" "eu_west_1_accept_us_east_1" {
  for_each                  = local.enable_map
  provider                  = aws.eu_west_1
  vpc_peering_connection_id = aws_vpc_peering_connection.us_east_1_to_eu_west_1["enabled"].id
  auto_accept               = true

  tags = merge(local.base_tags, { Name = "eu-west-1-accept-us-east-1" })
}


# US To London
resource "aws_vpc_peering_connection" "us_east_1_to_eu_west_2" {
  for_each    = local.enable_map
  provider    = aws.us_east_1
  vpc_id      = var.us_east_1_vpc_id
  peer_vpc_id = var.eu_west_2_vpc_id
  peer_region = "eu-west-2"
  auto_accept = false

  tags = merge(local.base_tags, { Name = "us-east-1-to-eu-west-2" })
}

# London To US
resource "aws_vpc_peering_connection_accepter" "eu_west_2_accept_us_east_1" {
  for_each                  = local.enable_map
  provider                  = aws.eu_west_2
  vpc_peering_connection_id = aws_vpc_peering_connection.us_east_1_to_eu_west_2["enabled"].id
  auto_accept               = true

  tags = merge(local.base_tags, { Name = "eu-west-2-accept-us-east-1" })
}

# Ireland To London
resource "aws_vpc_peering_connection" "eu_west_1_to_eu_west_2" {
  for_each    = local.enable_map
  provider    = aws.eu_west_1
  vpc_id      = var.eu_west_1_vpc_id
  peer_vpc_id = var.eu_west_2_vpc_id
  peer_region = "eu-west-2"
  auto_accept = false

  tags = merge(local.base_tags, { Name = "eu-west-1-to-eu-west-2" })
}

# London To Ireland
resource "aws_vpc_peering_connection_accepter" "eu_west_2_accept_eu_west_1" {
  for_each                  = local.enable_map
  provider                  = aws.eu_west_2
  vpc_peering_connection_id = aws_vpc_peering_connection.eu_west_1_to_eu_west_2["enabled"].id
  auto_accept               = true

  tags = merge(local.base_tags, { Name = "eu-west-2-accept-eu-west-1" })
}

# Routes configuration (Only the Applications' private Route Tables get routes)
resource "aws_route" "us_east_1_to_eu_west_1" {
  for_each = local.us_east_1_route_table_ids
  provider = aws.us_east_1

  route_table_id            = each.value
  destination_cidr_block    = local.eu_west_1_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_east_1_to_eu_west_1["enabled"].id
}

resource "aws_route" "eu_west_1_to_us_east_1" {
  for_each = local.eu_west_1_route_table_ids
  provider = aws.eu_west_1

  route_table_id            = each.value
  destination_cidr_block    = local.us_east_1_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_east_1_to_eu_west_1["enabled"].id
}

resource "aws_route" "us_east_1_to_eu_west_2" {
  for_each = local.us_east_1_route_table_ids
  provider = aws.us_east_1

  route_table_id            = each.value
  destination_cidr_block    = local.eu_west_2_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_east_1_to_eu_west_2["enabled"].id
}

resource "aws_route" "eu_west_2_to_us_east_1" {
  for_each = local.eu_west_2_route_table_ids
  provider = aws.eu_west_2

  route_table_id            = each.value
  destination_cidr_block    = local.us_east_1_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_east_1_to_eu_west_2["enabled"].id
}

resource "aws_route" "eu_west_1_to_eu_west_2" {
  for_each = local.eu_west_1_route_table_ids
  provider = aws.eu_west_1

  route_table_id            = each.value
  destination_cidr_block    = local.eu_west_2_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eu_west_1_to_eu_west_2["enabled"].id
}

resource "aws_route" "eu_west_2_to_eu_west_1" {
  for_each = local.eu_west_2_route_table_ids
  provider = aws.eu_west_2

  route_table_id            = each.value
  destination_cidr_block    = local.eu_west_1_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.eu_west_1_to_eu_west_2["enabled"].id
}
