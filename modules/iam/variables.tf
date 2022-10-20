# Tags

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "iam_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}
