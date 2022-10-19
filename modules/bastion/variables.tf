variable "vpc_security_group_ids" {
  description = "IDs of the security groups"
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

# Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "bastion_name" {
  description = "Name of the bastion instance"
  type        = string
}
