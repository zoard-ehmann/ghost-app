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

# Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "alb_name" {
  description = "Name of the application load balancer"
  type        = string
}

variable "tg_name" {
  description = "Name of the target group"
  type        = string
}

variable "listener_name" {
  description = "Name of the listener"
  type        = string
}
