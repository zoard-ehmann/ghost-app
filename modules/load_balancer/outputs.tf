output "lb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.ghost.dns_name
}
