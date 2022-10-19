variable "vpc_zone_identifier" {
  description = "Subnets of the VPC"
  type        = list(string)
}

variable "launch_template_id" {
  description = "ID of the launch template"
  type        = string
}

variable "lb_target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

# Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "asg_instance_name" {
  description = "Name of the EC2 instances within ASG"
  type        = string
}
