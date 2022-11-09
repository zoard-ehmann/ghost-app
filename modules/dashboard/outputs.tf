output "dashboard_iam_policy_arn" {
  description = "ARN of the dashboard IAM policy"
  value       = aws_iam_policy.this.arn
}
