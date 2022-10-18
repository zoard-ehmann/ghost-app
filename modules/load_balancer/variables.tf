variable "security_groups" {
  description = "Security groups for the ALB"
  type        = list(any)
}

variable "subnets" {
  description = "Subnets where the ALB operates"
  type        = list(any)
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB operates"
  type        = string
}
