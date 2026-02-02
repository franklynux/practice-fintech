terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "eu_west_1"
  region  = "eu-west-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "eu_west_2"
  region  = "eu-west-2"
  profile = var.aws_profile
}

data "terraform_remote_state" "us_east_1" {
  backend = "s3"
  config = {
    bucket  = var.state_bucket
    key     = var.us_east_1_state_key
    region  = var.state_bucket_region
    encrypt = true
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "eu_west_1" {
  backend = "s3"
  config = {
    bucket  = var.state_bucket
    key     = var.eu_west_1_state_key
    region  = var.state_bucket_region
    encrypt = true
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "eu_west_2" {
  backend = "s3"
  config = {
    bucket  = var.state_bucket
    key     = var.eu_west_2_state_key
    region  = var.state_bucket_region
    encrypt = true
    profile = var.aws_profile
  }
}

module "vpc_peering" {
  source = "../../../modules/vpc-peering"

  providers = {
    aws.us_east_1 = aws.us_east_1
    aws.eu_west_1 = aws.eu_west_1
    aws.eu_west_2 = aws.eu_west_2
  }

  enabled = var.enabled
  tags    = var.tags

  # VPC IDs of each region
  us_east_1_vpc_id = data.terraform_remote_state.us_east_1.outputs.vpc_id
  eu_west_1_vpc_id = data.terraform_remote_state.eu_west_1.outputs.vpc_id
  eu_west_2_vpc_id = data.terraform_remote_state.eu_west_2.outputs.vpc_id

  # VPC CIDRs of each region
  us_east_1_vpc_cidr = data.terraform_remote_state.us_east_1.outputs.vpc_cidr_block
  eu_west_1_vpc_cidr = data.terraform_remote_state.eu_west_1.outputs.vpc_cidr_block
  eu_west_2_vpc_cidr = data.terraform_remote_state.eu_west_2.outputs.vpc_cidr_block

  # Applications' Route Tables to pass peering routes into 
  us_east_1_private_route_table_ids = data.terraform_remote_state.us_east_1.outputs.app_private_route_table_ids
  eu_west_1_private_route_table_ids = data.terraform_remote_state.eu_west_1.outputs.app_private_route_table_ids
  eu_west_2_private_route_table_ids = data.terraform_remote_state.eu_west_2.outputs.app_private_route_table_ids
  
  # Private subnet IDs for test instances
  us_east_1_private_subnet_ids = data.terraform_remote_state.us_east_1.outputs.app_private_subnet_ids
  eu_west_1_private_subnet_ids = data.terraform_remote_state.eu_west_1.outputs.app_private_subnet_ids
  eu_west_2_private_subnet_ids = data.terraform_remote_state.eu_west_2.outputs.app_private_subnet_ids
}
