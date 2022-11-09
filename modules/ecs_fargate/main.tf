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

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "dashboard" {
  role       = aws_iam_role.this.name
  policy_arn = var.dashboard_iam_policy_arn
}

resource "aws_iam_instance_profile" "this" {
  name = var.ecs_iam_profile_name
  role = aws_iam_role.this.name

  tags = {
    Name    = var.ecs_iam_profile_name
    Project = var.project
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name    = var.ecs_cluster_name
    Project = var.project
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.ecs_task_def_name
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.this.arn
  execution_role_arn       = aws_iam_role.this.arn
  network_mode             = "awsvpc"
  memory                   = 1024
  cpu                      = 256

  volume {
    name = var.volume_name

    efs_volume_configuration {
      file_system_id = var.efs_id
    }
  }

  container_definitions = jsonencode([
    {
      "name" : "${var.container_name}",
      "image" : "${aws_ecr_repository.this.repository_url}:${var.ghost_version}",
      "essential" : true,
      "environment" : [
        { "name" : "database__client", "value" : "mysql" },
        { "name" : "database__connection__host", "value" : "${var.db_url}" },
        { "name" : "database__connection__user", "value" : "${var.db_username}" },
        { "name" : "database__connection__password", "value" : "${var.db_password}" },
        { "name" : "database__connection__database", "value" : "${var.db_name}" }
      ],
      "mountPoints" : [
        {
          "containerPath" : "/var/lib/ghost/content",
          "sourceVolume" : "${var.volume_name}"
        }
      ],
      "portMappings" : [
        {
          "containerPort" : 2368,
          "hostPort" : 2368
        }
      ]
    }
  ])

  tags = {
    Name    = var.ecs_task_def_name
    Project = var.project
  }
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.this.arn
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  depends_on      = [aws_iam_role.this]

  load_balancer {
    target_group_arn = var.fargate_lb_target_group_arn
    container_name   = var.container_name
    container_port   = 2368
  }

  network_configuration {
    assign_public_ip = false
    subnets          = var.ecs_subnets
    security_groups  = [aws_security_group.this.id]
  }

  tags = {
    Name    = var.service_name
    Project = var.project
  }
}
