resource "aws_security_group" "this" {
  name        = var.alb_sg_name
  description = "Allows access to ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name    = var.alb_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_host_ip" {
  description       = "Allows traffic from host IP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress_ec2_pool" {
  description              = "Allows traffic to EC2 pool"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.ec2_pool_sg_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]
  subnets            = var.subnets

  tags = {
    Name    = var.alb_name
    Project = var.project
  }
}

resource "aws_lb_target_group" "this" {
  name     = var.tg_name
  port     = 2368
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name    = var.tg_name
    Project = var.project
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn

    forward {
      target_group {
        arn    = aws_lb_target_group.this.arn
        weight = 100
      }
    }
  }

  tags = {
    Name    = var.listener_name
    Project = var.project
  }
}
