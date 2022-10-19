output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "subnet_a_id" {
  description = "ID of subnet A"
  value       = aws_subnet.a.id
}

output "subnet_b_id" {
  description = "ID of subnet B"
  value       = aws_subnet.b.id
}

output "subnet_c_id" {
  description = "ID of subnet C"
  value       = aws_subnet.c.id
}
