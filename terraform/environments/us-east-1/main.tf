terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "franklynux"
}

locals {
  region       = "us-east-1"
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

# module "postgres_primary" {
#   source = "../../../modules/postgres-primary"

#   name_prefix                 = "prod-${local.region}"
#   vpc_id                      = module.vpc.vpc_id
#   db_subnet_ids               = module.vpc.database_subnet_ids
#   app_subnet_ids              = module.vpc.app_private_subnet_ids
#   allowed_client_cidrs        = [module.vpc.vpc_cidr_block]
#   additional_db_ingress_cidrs = []

#   db_name               = "transactions"
#   db_master_username    = "txn_admin"
#   max_connections       = "1000"
#   create_read_replica   = false
#   backup_retention_days = 14
#   backup_window         = "02:00-03:00"
#   maintenance_window    = "sun:03:00-sun:04:00"

#   tags = local.common_tags

# }
