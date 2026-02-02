terraform {
  backend "s3" {
    bucket       = "xterns-s3-statefile-us-east-1"
    key          = "peering/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    profile      = "franklynux"
    use_lockfile = true
  }
}
