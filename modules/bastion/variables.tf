variable "vpc_security_group_ids" {
  description = "IDs of the security groups"
  type        = list(any)
}

variable "key_name" {
  description = "Name of SSH public key"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the instance should be deployed"
  type        = string
}
