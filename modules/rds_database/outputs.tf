output "db_url" {
  description = "URL of the database"
  value       = aws_db_instance.this.address
}

output "db_id" {
  description = "Identifier of the database"
  value       = aws_db_instance.this.id
}
