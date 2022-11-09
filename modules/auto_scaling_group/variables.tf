variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "bastion_sg_id" {
  description = "ID of bastion security group"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks for ingress traffic"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID of ALB security group"
  type        = string
}

variable "key_name" {
  description = "Name of SSH public key"
  type        = string
}

variable "lb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "db_url" {
  description = "URL of the database"
  type        = string
}

variable "db_username" {
  description = "Username of DB user"
  type        = string
}

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "vpc_zone_identifier" {
  description = "Subnets of the VPC"
  type        = list(string)
}

variable "ec2_lb_target_group_arn" {
  description = "ARN of the EC2 target group"
  type        = string
}

variable "ghost_version" {
  description = "Version of Ghost app"
  type        = string
}

variable "dashboard_iam_policy_arn" {
  description = "ARN of the dashboard IAM policy"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "asg_iam_role_name" {
  description = "Name of the ASG IAM role"
  type        = string
}

variable "asg_iam_policy_name" {
  description = "Name of the ASG IAM policy"
  type        = string
}

variable "asg_iam_profile_name" {
  description = "Name of the ASG IAM instance profile"
  type        = string
}

variable "ec2_pool_sg_name" {
  description = "EC2 pool security group name"
  type        = string
}

variable "launch_template_name" {
  description = "Name of the launch template"
  type        = string
}

variable "asg_instance_name" {
  description = "Name of the EC2 instances within ASG"
  type        = string
}

variable "asg_name" {
  description = "Name of the ASG"
  type        = string
}
