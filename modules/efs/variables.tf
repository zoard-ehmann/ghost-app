variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ec2_pool_sg_id" {
  description = "ID of EC2 pool security group"
  type        = string
}

variable "fargate_pool_sg_id" {
  description = "ID of Fargate pool security group"
  type        = string
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks for egress traffic"
  type        = list(string)
}

variable "subnet_a_id" {
  description = "ID of subnet A"
  type        = string
}

variable "subnet_b_id" {
  description = "ID of subnet B"
  type        = string
}

variable "subnet_c_id" {
  description = "ID of subnet C"
  type        = string
}

# INFO: Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "efs_sg_name" {
  description = "Elastic file system security group name"
  type        = string
}

variable "efs_name" {
  description = "Name of elastic file system"
  type        = string
}
