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
  default     = "xterns-s3-statefile-us-east-1"
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

variable "enable_cross_region_lb" {
  description = "Enable traffic through Global Accelerator once regional endpoints are ready."
  type        = bool
  default     = false
}

variable "cross_region_lb_name" {
  description = "Name of the cross-region Global Accelerator."
  type        = string
  default     = "fintech-prod-global-accelerator"
}

variable "cross_region_lb_listener_port" {
  description = "Listener port exposed by Global Accelerator."
  type        = number
  default     = 443
}

variable "cross_region_lb_listener_protocol" {
  description = "Listener protocol exposed by Global Accelerator."
  type        = string
  default     = "TCP"
}

variable "cross_region_lb_endpoint_arns" {
  description = "Map of region to ALB/NLB endpoint ARNs. Leave empty until regional ingress resources exist."
  type        = map(list(string))
  default = {
    us-east-1 = []
    eu-west-1 = []
    eu-west-2 = []
  }
}

variable "cross_region_lb_health_check_port" {
  description = "Health check port for Global Accelerator endpoint groups."
  type        = number
  default     = 443
}

variable "cross_region_lb_health_check_protocol" {
  description = "Health check protocol for Global Accelerator endpoint groups."
  type        = string
  default     = "HTTPS"
}

variable "cross_region_lb_health_check_path" {
  description = "Health check path for Global Accelerator endpoint groups."
  type        = string
  default     = "/healthz"
}
