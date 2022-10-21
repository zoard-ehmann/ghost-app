output "sg_id" {
  description = "ID of bastion security group"
  value       = aws_security_group.this.id
}

output "bastion_dns" {
  description = "DNS of the bastion"
  value       = aws_instance.this.public_dns
}
