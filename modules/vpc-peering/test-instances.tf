# Test EC2 instances for valid peering connectivity
/* resource "aws_instance" "test_us_east_1" {
  for_each      = local.enable_map
  provider      = aws.us_east_1
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = var.us_east_1_private_subnet_ids[0]
  
  vpc_security_group_ids = [aws_security_group.test_sg_us_east_1["enabled"].id]
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y tcpdump
  EOF
  
  tags = merge(local.base_tags, { Name = "test-us-east-1" })
}

resource "aws_instance" "test_eu_west_1" {
  for_each      = local.enable_map
  provider      = aws.eu_west_1
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = var.eu_west_1_private_subnet_ids[0]
  
  vpc_security_group_ids = [aws_security_group.test_sg_eu_west_1["enabled"].id]
  
  tags = merge(local.base_tags, { Name = "test-eu-west-1" })
}

resource "aws_instance" "test_eu_west_2" {
  for_each      = local.enable_map
  provider      = aws.eu_west_2
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = var.eu_west_2_private_subnet_ids[0]
  
  vpc_security_group_ids = [aws_security_group.test_sg_eu_west_2["enabled"].id]
  
  tags = merge(local.base_tags, { Name = "test-eu-west-2" })
}

# Security groups for test instances
resource "aws_security_group" "test_sg_us_east_1" {
  for_each    = local.enable_map
  provider    = aws.us_east_1
  name        = "Test SG"
  description = "Security group for VPC peering test"
  vpc_id      = var.us_east_1_vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.eu_west_1_cidr_block, local.eu_west_2_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, { Name = "test-sg-us-east-1" })
}

resource "aws_security_group" "test_sg_eu_west_1" {
  for_each    = local.enable_map
  provider    = aws.eu_west_1
  name        = "Test SG"
  description = "Security group for VPC peering test"
  vpc_id      = var.eu_west_1_vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.us_east_1_cidr_block, local.eu_west_2_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, { Name = "test-sg-eu-west-1" })
}

resource "aws_security_group" "test_sg_eu_west_2" {
  for_each    = local.enable_map
  provider    = aws.eu_west_2
  name        = "Test SG"
  description = "Security group for VPC peering test"
  vpc_id      = var.eu_west_2_vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.us_east_1_cidr_block, local.eu_west_1_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.base_tags, { Name = "test-sg-eu-west-2" })
} */