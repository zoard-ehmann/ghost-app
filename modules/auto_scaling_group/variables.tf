variable "vpc_zone_identifier" {
  description = "Subnets of the VPC"
  type        = list(any)
}

variable "launch_template_id" {
  description = "ID of the launch template"
  type        = string
}

variable "lb_target_group_arn" {
  description = "ARN of the target group"
  type        = string
}
