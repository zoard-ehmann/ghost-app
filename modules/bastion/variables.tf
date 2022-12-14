variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks for ingress traffic"
  type        = list(string)
}

variable "key_name" {
  description = "Name of SSH public key"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the instance should be deployed"
  type        = string
}

variable "host_username" {
  description = "Username on the host machine (helps to locate SSH private key)"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the SSH key-pair"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "bastion_sg_name" {
  description = "Bastion security group name"
  type        = string
}

variable "bastion_name" {
  description = "Name of the bastion instance"
  type        = string
}
