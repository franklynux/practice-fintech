terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# bootstrap module for backend infrastructure (this creates all regional resources)
module "bootstrap" {
  source = "./terraform/bootstrap"

  bucket_name = var.bucket_name
}



