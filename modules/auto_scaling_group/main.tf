resource "aws_iam_role" "this" {
  name = var.asg_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name    = var.asg_iam_role_name
    Project = var.project
  }
}

resource "aws_iam_policy" "this" {
  name        = var.asg_iam_policy_name
  description = "Allows EC2 Describe*, EFS DescribeFS, EFS ClientMount & ClientWrite"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeFileSystems",
        "ssm:GetParameter*",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  tags = {
    Name    = var.asg_iam_policy_name
    Project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "dashboard" {
  role       = aws_iam_role.this.name
  policy_arn = var.dashboard_iam_policy_arn
}

resource "aws_iam_instance_profile" "this" {
  name = var.asg_iam_profile_name
  role = aws_iam_role.this.name

  tags = {
    Name    = var.asg_iam_profile_name
    Project = var.project
  }
}

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
    arn = aws_iam_instance_profile.this.arn
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = var.launch_template_name
      Project = var.project
    }
  }

  user_data = base64encode(templatefile("${path.module}/setupGhost.sh", {
    lb_dns_name   = var.lb_dns_name
    db_url        = var.db_url
    db_username   = var.db_username
    db_name       = var.db_name
    ghost_version = var.ghost_version
  }))
}

resource "aws_autoscaling_group" "this" {
  name                = var.asg_name
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = [var.ec2_lb_target_group_arn]

  # BUG
  # ------------------------------ #
  # Manual refresh is required in case of launch template change
  # The following feature is not working at the moment:
  # https://github.com/hashicorp/terraform-provider-aws/issues/23274
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }
  # ------------------------------ #

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
