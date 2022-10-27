resource "aws_security_group" "this" {
  name        = var.ecs_sg_name
  description = "Allows access for Fargate instances"
  vpc_id      = var.vpc_id

  tags = {
    Name    = var.ecs_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_efs" {
  description              = "Allows access from EFS"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.efs_sg_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_alb" {
  description              = "Allows access from ALB"
  type                     = "ingress"
  to_port                  = 2368
  from_port                = 2368
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

resource "aws_ecr_repository" "this" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name    = var.ecr_name
    Project = var.project
  }
}

resource "aws_iam_role" "this" {
  name = var.ecs_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name    = var.ecs_iam_role_name
    Project = var.project
  }
}

resource "aws_iam_policy" "this" {
  name        = var.ecs_iam_policy_name
  description = "Allows ECR Gets, EFS DescribeFS, ClientMount and ClientWrite"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  tags = {
    Name    = var.ecs_iam_policy_name
    Project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = var.ecs_iam_profile_name
  role = aws_iam_role.this.name

  tags = {
    Name    = var.ecs_iam_profile_name
    Project = var.project
  }
}
