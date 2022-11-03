output "sg_id" {
  description = "ID of ALB security group"
  value       = aws_security_group.this.id
}

output "lb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "ec2_lb_target_group_arn" {
  description = "ARN of the EC2 target group"
  value       = aws_lb_target_group.ec2.arn
}

output "fargate_lb_target_group_arn" {
  description = "ARN of the Fargate target group"
  value       = aws_lb_target_group.fargate.arn
}
