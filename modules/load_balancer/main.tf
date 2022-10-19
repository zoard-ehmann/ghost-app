resource "aws_lb" "ghost" {
  name               = "ghost-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = {
    Name    = var.alb_name
    Project = var.project
  }
}

resource "aws_lb_target_group" "ghost" {
  name     = "ghost-ec2"
  port     = 2368
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name    = var.tg_name
    Project = var.project
  }
}

resource "aws_lb_listener" "ghost" {
  load_balancer_arn = aws_lb.ghost.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost.arn

    forward {
      target_group {
        arn    = aws_lb_target_group.ghost.arn
        weight = 100
      }
    }
  }

  tags = {
    Name    = var.listener_name
    Project = var.project
  }
}
