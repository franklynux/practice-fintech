terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "franklynux"
}

locals {
  region       = "eu-west-1"
  cluster_name = "prod-eks-${local.region}"

  common_tags = {
    Environment = "production"
    Region      = local.region
    Workload    = "fintech-platform"
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name       = local.cluster_name
  private_subnet_ids = module.vpc.app_private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  tags               = local.common_tags
}

# data "terraform_remote_state" "primary_us_east_1" {
#   backend = "s3"

#   config = {
#     bucket  = "xterns-s3-statefile-us-east-1"
#     key     = "us-east-1/terraform.tfstate"
#     region  = "us-east-1"
#     profile = "franklynux"
#   }
# }

# module "postgres_replica" {
#   source = "../../../modules/postgres-cross-region-replica"

#   name_prefix           = "prod-${local.region}"
#   vpc_id                = module.vpc.vpc_id
#   db_subnet_ids         = module.vpc.database_subnet_ids
#   source_db_arn         = data.terraform_remote_state.primary_us_east_1.outputs.postgres_primary_db_instance_arn
#   multi_az              = true
#   max_connections       = "1000"
#   backup_retention_days = 14
#   backup_window         = "02:00-03:00"
#   maintenance_window    = "sun:03:00-sun:04:00"
#   allowed_client_cidrs  = [module.vpc.vpc_cidr_block]

#   tags = merge(
#     local.common_tags,
#     {
#       Component = "postgres-transaction-replica"
#     }
#   )
# }

