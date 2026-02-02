variable "enabled" {
  description = "option to create the VPC peering mesh"
  type        = bool
  default     = true
}

variable "us_east_1_vpc_id" {
  description = "VPC ID for us-east-1"
  type        = string
}

variable "eu_west_1_vpc_id" {
  description = "VPC ID for eu-west-1"
  type        = string
}

variable "eu_west_2_vpc_id" {
  description = "VPC ID for eu-west-2"
  type        = string
}


variable "us_east_1_vpc_cidr" {
  description = "VPC CIDR Block for us-east-1"
  type        = string
  
}

variable "eu_west_1_vpc_cidr" {
  description = "VPC CIDR Block for eu-west-1"
  type        = string
  
}

variable "eu_west_2_vpc_cidr" {
  description = "VPC CIDR Block for eu-west-2"
  type        = string
  
}

variable "eu_west_2_private_route_table_ids" {
  description = "A list of private route table IDs where the peering connection route will be created"
  type        = list(string)
  
}

variable "eu_west_1_private_route_table_ids" {
  description = "A list of private route table IDs where the peering connection route will be created"
  type        = list(string)
  
}

variable "us_east_1_private_route_table_ids" {
  description = "A list of private route table IDs where the peering connection route will be created"
  type        = list(string)
  
}
variable "tags" {
  description = "Tags applied to peering connections"
  type        = map(string)
  default     = {}
}

/* 
variable "us_east_1_private_subnet_ids" {
  description = "Private subnet IDs for us-east-1 test instances"
  type        = list(string)
  default     = []
}

variable "eu_west_1_private_subnet_ids" {
  description = "Private subnet IDs for eu-west-1 test instances"
  type        = list(string)
  default     = []
}

variable "eu_west_2_private_subnet_ids" {
  description = "Private subnet IDs for eu-west-2 test instances"
  type        = list(string)
  default     = []
} 

variable "private_route_table_name_filters" {
  description = "Name tag filters used to select private route tables only."
  type        = list(string)
  default     = ["*-private_rt_1", "*-private_rt_2", "*-private_rt_3"]
}
*/
