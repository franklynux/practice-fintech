variable "enabled" {
  description = "Whether to create the VPC peering mesh."
  type        = bool
  default     = true
}

variable "aws_profile" {
  description = "AWS CLI profile to use for providers and remote state."
  type        = string
  default     = "franklynux"
}

variable "state_bucket" {
  description = "S3 bucket storing the regional Terraform states."
  type        = string
  default     = "xterns-statefile-us-east-1"
}

variable "state_bucket_region" {
  description = "AWS region where the state bucket lives."
  type        = string
  default     = "us-east-1"
}

variable "us_east_1_state_key" {
  description = "S3 key for the us-east-1 environment state."
  type        = string
  default     = "us-east-1/terraform.tfstate"
}

variable "eu_west_1_state_key" {
  description = "S3 key for the eu-west-1 environment state."
  type        = string
  default     = "eu-west-1/terraform.tfstate"
}

variable "eu_west_2_state_key" {
  description = "S3 key for the eu-west-2 environment state."
  type        = string
  default     = "eu-west-2/terraform.tfstate"
}

variable "tags" {
  description = "Tags applied to VPC peering resources."
  type        = map(string)
  default     = {}
}

variable "private_route_table_name_filters" {
  description = "Name tag filters used to select private route tables only."
  type        = list(string)
  default     = ["*-private_rt_1", "*-private_rt_2", "*-private_rt_3"]
}
