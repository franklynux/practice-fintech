terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  common_tags = merge(
    {
      ManagedBy = "terraform"
      Component = "cross-region-lb"
    },
    var.tags
  )

  endpoint_groups = {
    for region, endpoint_arns in var.regional_endpoint_arns :
    region => endpoint_arns
    if length(endpoint_arns) > 0
  }
}

resource "aws_globalaccelerator_accelerator" "this" {
  name            = var.name
  enabled         = var.enable_cross_region_lb
  ip_address_type = "IPV4"

  tags = local.common_tags
}

resource "aws_globalaccelerator_listener" "this" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = var.listener_protocol

  port_range {
    from_port = var.listener_port
    to_port   = var.listener_port
  }
}

resource "aws_globalaccelerator_endpoint_group" "regional" {
  for_each = local.endpoint_groups

  listener_arn            = aws_globalaccelerator_listener.this.id
  endpoint_group_region   = each.key
  health_check_path       = var.health_check_path
  health_check_port       = var.health_check_port
  health_check_protocol   = var.health_check_protocol
  traffic_dial_percentage = var.enable_cross_region_lb ? 100 : 0

  dynamic "endpoint_configuration" {
    for_each = each.value

    content {
      endpoint_id = endpoint_configuration.value
      weight      = 100
    }
  }
}
