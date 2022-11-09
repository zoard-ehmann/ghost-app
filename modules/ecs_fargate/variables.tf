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

variable "efs_id" {
  description = "ID of the EFS"
  type        = string
}

variable "db_url" {
  description = "URL of the database"
  type        = string
}

variable "db_username" {
  description = "Username of DB user"
  type        = string
}

variable "db_password" {
  description = "Password of DB user"
  type        = string
}

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "fargate_lb_target_group_arn" {
  description = "ARN of the Fargate target group"
  type        = string
}

variable "ecs_subnets" {
  description = "Subnets for ECS to operate on"
  type        = list(string)
}

variable "ghost_version" {
  description = "Version of Ghost app"
  type        = string
}

variable "dashboard_iam_policy_arn" {
  description = "ARN of the dashboard IAM policy"
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

variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
  type        = string
}

variable "ecs_task_def_name" {
  description = "Name of ECS task definition"
  type        = string
}

variable "volume_name" {
  description = "Name of volume"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "image_name" {
  description = "Name of the app image"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
}
