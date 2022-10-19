resource "aws_security_group" "this" {
  name        = var.ec2_pool_sg_name
  description = "Allows access to EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name    = var.ec2_pool_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_bastion" {
  description              = "Allows SSH from bastion"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.bastion_sg_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_vpc" {
  description       = "Allows traffic from VPC"
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_alb" {
  description              = "Allows traffic from ALB"
  type                     = "ingress"
  from_port                = 2368
  to_port                  = 2368
  protocol                 = "tcp"
  source_security_group_id = var.alb_sg_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress_anywhere" {
  description       = "Allows traffic to anywhere"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_launch_template" "this" {
  name                   = var.launch_template_name
  image_id               = "ami-026b57f3c383c2eec"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.key_name
  update_default_version = true

  iam_instance_profile {
    arn = var.iam_profile_arn
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = var.launch_template_name
      Project = var.project
    }
  }

  user_data = base64encode(templatefile("${path.module}/setupGhost.sh", {
    lb_dns_name = var.lb_dns_name
  }))
}

resource "aws_autoscaling_group" "this" {
  name                = "ghost_ec2_pool"
  max_size            = 4
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.asg_instance_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = var.lb_target_group_arn
}
