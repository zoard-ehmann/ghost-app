resource "aws_security_group" "this" {
  name        = var.efs_sg_name
  description = "Defines access to EFS mount points"
  vpc_id      = var.vpc_id

  tags = {
    Name    = var.efs_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_ec2_pool" {
  description              = "Allows access from EC2 pool"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.ec2_pool_sg_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_fargate_pool" {
  description              = "Allows access from Fargate pool"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.fargate_pool_sg_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress_vpc" {
  description       = "Allows traffic to VPC"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_efs_file_system" "this" {
  tags = {
    Name    = var.efs_name
    Project = var.project
  }
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_a_id
  security_groups = [aws_security_group.this.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_b_id
  security_groups = [aws_security_group.this.id]
}

resource "aws_efs_mount_target" "c" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_c_id
  security_groups = [aws_security_group.this.id]
}
