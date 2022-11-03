output "sg_id" {
  description = "ID of EFS security group"
  value       = aws_security_group.this.id
}

output "efs_id" {
  description = "ID of the EFS"
  value       = aws_efs_file_system.this.id
}
