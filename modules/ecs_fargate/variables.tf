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

# INFO: Tags

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

variable "ecs_iam_role_name" {
  description = "Name of the ECS IAM role"
  type        = string
}

variable "ecs_iam_policy_name" {
  description = "Name of the ECS IAM policy"
  type        = string
}

variable "ecs_iam_profile_name" {
  description = "Name of the ECS IAM instance profile"
  type        = string
}
