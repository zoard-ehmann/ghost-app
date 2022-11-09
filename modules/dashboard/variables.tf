variable "region" {
  description = "AWS region"
  type        = string
}

variable "asg_name" {
  description = "Name of the ASG"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
  type        = string
}

variable "efs_id" {
  description = "ID of the EFS"
  type        = string
}

variable "db_id" {
  description = "Identifier of the database"
  type        = string
}

# INFO: Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "dashboard_iam_policy_name" {
  description = "Name of the CloudWatch Dashboard IAM policy"
  type        = string
}

variable "cw_dashboard_name" {
  description = "Name of CloudWatch Dashboard"
  type        = string
}
