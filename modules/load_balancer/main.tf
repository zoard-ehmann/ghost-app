resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
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
