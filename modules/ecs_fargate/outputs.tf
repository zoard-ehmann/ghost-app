output "sg_id" {
  description = "ID of Fargate pool security group"
  value       = aws_security_group.this.id
}
