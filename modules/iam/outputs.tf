output "iam_profile_arn" {
  description = "ARN of the IAM profile"
  value       = aws_iam_instance_profile.this.arn
}
