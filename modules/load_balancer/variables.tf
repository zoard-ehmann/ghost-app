variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks for ingress traffic"
  type        = list(string)
}

variable "ec2_pool_sg_id" {
  description = "ID of EC2 pool security group"
  type        = string
}

variable "subnets" {
  description = "Subnets where the ALB operates"
  type        = list(string)
}

# INFO: Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "alb_sg_name" {
  description = "Load balancer security group name"
  type        = string
}

variable "alb_name" {
  description = "Name of the application load balancer"
  type        = string
}

variable "ec2_tg_name" {
  description = "Name of the target group"
  type        = string
}

variable "listener_name" {
  description = "Name of the listener"
  type        = string
}
