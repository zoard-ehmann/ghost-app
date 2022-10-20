variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ec2_pool_sg_id" {
  description = "ID of EC2 pool security group"
  type        = string
}

variable "db_subnet_ids" {
  description = "Database subnet IDs"
  type        = list(string)
}

variable "db_username" {
  description = "Username of DB user"
  type        = string
}

variable "db_password" {
  description = "Password of DB user"
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

variable "db_subnet_grp_name" {
  description = "Name of DB subnet group"
  type        = string
}

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "ssm_parameter_name" {
  description = "Name of SSM parameter"
  type        = string
}
