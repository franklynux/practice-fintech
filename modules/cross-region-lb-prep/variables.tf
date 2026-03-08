variable "name" {
  description = "Global Accelerator name."
  type        = string
  default     = "fintech-prod-global-accelerator"
}

variable "enable_cross_region_lb" {
  description = "Enables traffic flow through the accelerator."
  type        = bool
  default     = false
}

variable "listener_port" {
  description = "Port exposed by the accelerator listener."
  type        = number
  default     = 443
}

variable "listener_protocol" {
  description = "Protocol exposed by the accelerator listener."
  type        = string
  default     = "TCP"
}

variable "regional_endpoint_arns" {
  description = "Map of region => endpoint ARN list (for example ALB/NLB ARNs)."
  type        = map(list(string))
  default     = {}
}

variable "health_check_port" {
  description = "Health check port for endpoint groups."
  type        = number
  default     = 443
}

variable "health_check_protocol" {
  description = "Health check protocol for endpoint groups."
  type        = string
  default     = "HTTPS"
}

variable "health_check_path" {
  description = "Health check path for endpoint groups."
  type        = string
  default     = "/healthz"
}

variable "tags" {
  description = "Tags for Global Accelerator resources."
  type        = map(string)
  default     = {}
}
