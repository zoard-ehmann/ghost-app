output "sg_id" {
  description = "ID of EC2 pool security group"
  value       = aws_security_group.this.id
}
