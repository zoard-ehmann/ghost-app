resource "aws_security_group" "this" {
  name        = var.rds_sg_name
  description = "Defines access to DB"
  vpc_id      = var.vpc_id

  tags = {
    Name    = var.rds_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_ec2_pool" {
  description              = "Allows access from EC2 pool"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.ec2_pool_sg_id
  security_group_id        = aws_security_group.this.id
}
