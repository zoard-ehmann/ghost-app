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

variable "igw_name" {
  description = "Name of internet gateway"
  type        = string
}

variable "rt_name" {
  description = "Name of route table"
  type        = string
}
