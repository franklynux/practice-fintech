variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "eu-west-1"
}

variable "availability_zones" {
  description = "List of Availability Zones to use for the VPC"
  type        = list(string)
  default     = []
}

variable "max_azs" {
  description = "Maximum number of Availability Zones to use if none are specified"
  type        = number
  default     = 3
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 3
}

variable "app_private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.8.0/22", "10.1.12.0/22", "10.1.16.0/22"]
}

variable "app_private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 3
}

variable "database_subnet_count" {
  description = "Number of database subnets"
  type        = number
  default     = 3
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.1.20.0/24", "10.1.21.0/24", "10.1.22.0/24"]
}

variable "cde_subnet_count" {
  description = "Number of CDE subnets"
  type        = number
  default     = 3
}

variable "cde_subnet_cidrs" {
  description = "CIDR blocks for CDE subnets"
  type        = list(string)
  default     = ["10.1.30.0/24", "10.1.31.0/24", "10.1.32.0/24"]
}

#cloudwatch log retention duration variable
variable "retention_in_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}