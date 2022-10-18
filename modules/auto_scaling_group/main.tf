resource "aws_autoscaling_group" "ghost" {
  name                = "ghost_ec2_pool"
  max_size            = 4
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ghost-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "cloudx"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "ghost" {
  autoscaling_group_name = aws_autoscaling_group.ghost.id
  lb_target_group_arn    = var.lb_target_group_arn
}
