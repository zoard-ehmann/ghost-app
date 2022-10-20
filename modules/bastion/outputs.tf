output "sg_id" {
  description = "ID of bastion security group"
  value       = aws_security_group.this.id
}
