variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "efs_sg_id" {
  description = "ID of EFS security group"
  type        = string
}

variable "alb_sg_id" {
  description = "ID of ALB security group"
  type        = string
}

# Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "ecs_sg_name" {
  description = "Fargate pool security group name"
  type        = string
}

variable "ecr_name" {
  description = "Name of ECR"
  type        = string
}
