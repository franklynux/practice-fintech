# Create VPC in UK Region
resource "aws_vpc" "us-east-1-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}

# Get list of Availability Zones in a Region
data "aws_availability_zones" "AZs" {
  state = "available" # Filter for available availability zones
}

# Flexible AZ selection logic
locals {
  # Use provided AZs or auto-select from available ones
  selected_azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.AZs.names, 0, min(length(data.aws_availability_zones.AZs.names), var.max_azs))
}

# Create Subnets in selected Availability Zones
resource "aws_subnet" "public_subnets" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.us-east-1-vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.us-east-1-vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create a Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.us-east-1-vpc.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Create a route in the public route table to direct internet-bound traffic to the Internet Gateway
resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create Private Subnets
resource "aws_subnet" "app_private_subnets" {
  count                   = var.app_private_subnet_count
  vpc_id                  = aws_vpc.us-east-1-vpc.id
  cidr_block              = var.app_private_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index % length(local.selected_azs)]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-private_subnet_${count.index + 1}"
  }
}

# Create a NAT Gateway in the first public subnet
resource "aws_nat_gateway" "private_subnet_natGW_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnets[0].id # Use public subnet
  tags = {
    Name = "${var.vpc_name}-private_natGW_1"
  }
}

# Create an Elastic IP for the NAT Gateway 1
resource "aws_eip" "nat_eip_1" {
  domain = "vpc" # Specify that the Elastic IP is for a VPC
  tags = {
    Name = "${var.vpc_name}-nat_eip_1"
  }
}


# Create a NAT Gateway in the second public subnet
resource "aws_nat_gateway" "private_subnet_natGW_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnets[1].id # Use public subnet
  tags = {
    Name = "${var.vpc_name}-private_natGW_2"
  }
}

# Create an Elastic IP for the NAT Gateway 2
resource "aws_eip" "nat_eip_2" {
  domain = "vpc" # Specify that the Elastic IP is for a VPC
  tags = {
    Name = "${var.vpc_name}-nat_eip_2"
  }
}

# Create a NAT Gateway in the third public subnet
resource "aws_nat_gateway" "private_subnet_natGW_3" {
  allocation_id = aws_eip.nat_eip_3.id
  subnet_id     = aws_subnet.public_subnets[2].id
  tags = {
    Name = "${var.vpc_name}-private_natGW_3"
  }
}

# Create an Elastic IP for the NAT Gateway 3
resource "aws_eip" "nat_eip_3" {
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-nat_eip_3"
  }
}

# Create Route Tables for Private Subnets
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.us-east-1-vpc.id
  tags = {
    Name = "${var.vpc_name}-private_rt_1"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.us-east-1-vpc.id
  tags = {
    Name = "${var.vpc_name}-private_rt_2"
  }
}

resource "aws_route_table" "private_rt_3" {
  vpc_id = aws_vpc.us-east-1-vpc.id
  tags = {
    Name = "${var.vpc_name}-private_rt_3"
  }
}

# Create Routes for Private Route Tables to use NAT Gateways
resource "aws_route" "nat_route_1" {
  route_table_id         = aws_route_table.private_rt_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_subnet_natGW_1.id
}

resource "aws_route" "nat_route_2" {
  route_table_id         = aws_route_table.private_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_subnet_natGW_2.id
}

resource "aws_route" "nat_route_3" {
  route_table_id         = aws_route_table.private_rt_3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_subnet_natGW_3.id
}

# Associate Private Subnets with their respective Route Tables
resource "aws_route_table_association" "private_rt_assoc" {
  count          = var.app_private_subnet_count
  subnet_id      = aws_subnet.app_private_subnets[count.index].id
  route_table_id = count.index % 3 == 0 ? aws_route_table.private_rt_1.id : (count.index % 3 == 1 ? aws_route_table.private_rt_2.id : aws_route_table.private_rt_3.id)
}


# Database Subnets (isolated for security, no internet access)
resource "aws_subnet" "database_subnets" {
  count                   = var.database_subnet_count
  vpc_id                  = aws_vpc.us-east-1-vpc.id
  cidr_block              = var.database_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index % length(local.selected_azs)]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-database_subnet_${count.index + 1}"
  }
}


# Route table for Database Subnets (local VPC traffic only)
resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.us-east-1-vpc.id
  tags = {
    Name = "${var.vpc_name}-database_rt"
  }
}

# Associate Database Subnets with database route table
resource "aws_route_table_association" "database_rt_assoc" {
  count          = var.database_subnet_count
  subnet_id      = aws_subnet.database_subnets[count.index].id
  route_table_id = aws_route_table.database_rt.id
}


# CDE Subnets (isolated for security, no internet access)
resource "aws_subnet" "cde_subnets" {
  count                   = var.cde_subnet_count
  vpc_id                  = aws_vpc.us-east-1-vpc.id
  cidr_block              = var.cde_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index % length(local.selected_azs)]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-cde_subnet_${count.index + 1}"
  }
}

# Route table for CDE subnets (local VPC traffic only)
resource "aws_route_table" "cde_rt" {
  vpc_id = aws_vpc.us-east-1-vpc.id
  tags = {
    Name = "${var.vpc_name}-cde_rt"
  }
}

# Associate CDE Subnets with CDE route table
resource "aws_route_table_association" "cde_rt_assoc" {
  count          = var.cde_subnet_count
  subnet_id      = aws_subnet.cde_subnets[count.index].id
  route_table_id = aws_route_table.cde_rt.id
}

# VPC Flow Logs Configuration
# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "eu_west_2_vpc_flow_logs" {
  name              = "/aws/vpc/${var.vpc_name}-flow-logs"
  retention_in_days = var.retention_in_days
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "eu_west_2_vpc_flow_logs_role" {
  name = "${var.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "eu_west_2_vpc_flow_logs_policy" {
  name = "${var.vpc_name}-flow-logs-policy"
  role = aws_iam_role.eu_west_2_vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# Data Protection Policy for PCI Compliance
resource "aws_cloudwatch_log_data_protection_policy" "pci_data_protection" {
  log_group_name = aws_cloudwatch_log_group.eu_west_2_vpc_flow_logs.name

  policy_document = jsonencode({
    Name    = "PCI-Data-Protection-Policy"
    Version = "2021-06-01"

    Statement = [{
      Sid = "Audit"
      DataIdentifier = [
        "arn:aws:dataprotection::aws:data-identifier/CreditCardNumber",
        "arn:aws:dataprotection::aws:data-identifier/CreditCardExpiration",
        "arn:aws:dataprotection::aws:data-identifier/CreditCardSecurityCode"
      ]
      Operation = {
        Audit = {
          FindingsDestination = {}
        }
      }
      }, {
      Sid = "Redact"
      DataIdentifier = [
        "arn:aws:dataprotection::aws:data-identifier/CreditCardNumber",
        "arn:aws:dataprotection::aws:data-identifier/CreditCardExpiration",
        "arn:aws:dataprotection::aws:data-identifier/CreditCardSecurityCode"
      ]
      Operation = {
        Deidentify = {
          MaskConfig = {}
        }
      }
    }]
  })
}

# VPC Flow Logs
resource "aws_flow_log" "eu_west_2_vpc_flow_log" {
  vpc_id               = aws_vpc.us-east-1-vpc.id
  traffic_type         = "ALL"
  iam_role_arn         = aws_iam_role.eu_west_2_vpc_flow_logs_role.arn
  log_destination      = aws_cloudwatch_log_group.eu_west_2_vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  tags = {
    Name = "${var.vpc_name}-flow-log"
  }

  depends_on = [aws_cloudwatch_log_data_protection_policy.pci_data_protection]
}
