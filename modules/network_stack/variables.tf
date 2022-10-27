# INFO: Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "subnet_a_name" {
  description = "Name of subnet A"
  type        = string
}

variable "subnet_b_name" {
  description = "Name of subnet B"
  type        = string
}

variable "subnet_c_name" {
  description = "Name of subnet C"
  type        = string
}

variable "subnet_db_a_name" {
  description = "Name of DB subnet A"
  type        = string
}

variable "subnet_db_b_name" {
  description = "Name of DB subnet B"
  type        = string
}

variable "subnet_db_c_name" {
  description = "Name of DB subnet C"
  type        = string
}

variable "subnet_ecs_a_name" {
  description = "Name of ECS subnet A"
  type        = string
}

variable "subnet_ecs_b_name" {
  description = "Name of  ECS subnet B"
  type        = string
}

variable "subnet_ecs_c_name" {
  description = "Name of  ECS subnet C"
  type        = string
}

variable "igw_name" {
  description = "Name of internet gateway"
  type        = string
}

variable "public_rt_name" {
  description = "Name of public route table"
  type        = string
}

variable "private_rt_name" {
  description = "Name of private route table"
  type        = string
}
