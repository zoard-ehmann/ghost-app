variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ec2_pool_sg_id" {
  description = "ID of EC2 pool security group"
  type        = string
}

# Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "rds_sg_name" {
  description = "RDS security group name"
  type        = string
}
