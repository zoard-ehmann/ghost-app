# INFO: Set up variables

variable "ssh_public_key" {
  description = "SSH public key to connect to the instances"
  type        = string
}

variable "project" {
  description = "Name of VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "subnet_a_name" {
  description = "Name of subnet A"
  type        = string
}

variable "subnet_b_name" {
  description = "Name of subnet B"
  type        = string
}

variable "subnet_c_name" {
  description = "Name of subnet C"
  type        = string
}

variable "igw_name" {
  description = "Name of internet gateway"
  type        = string
}

variable "rt_name" {
  description = "Name of route table"
  type        = string
}

# INFO: Set up data sources

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# INFO: Set up provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


# INFO: Create network stack

module "network_stack" {
  source = "./modules/network_stack"

  project       = var.project
  vpc_name      = var.vpc_name
  subnet_a_name = var.subnet_a_name
  subnet_b_name = var.subnet_b_name
  subnet_c_name = var.subnet_c_name
  igw_name      = var.igw_name
  rt_name       = var.rt_name
}

# INFO: Create security groups

### BASTION ###

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allows access to bastion"
  vpc_id      = module.network_stack.vpc_id

  tags = {
    Name    = "bastion"
    Project = "cloudx"
  }
}

resource "aws_security_group_rule" "bastion_ingress_myip" {
  description       = "Allows SSH from my IP"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress_anywhere" {
  description       = "Allows traffic to anywhere"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

### EC2 POOL ###

resource "aws_security_group" "ec2_pool" {
  name        = "ec2_pool"
  description = "Allows access to ec2 instances"
  vpc_id      = module.network_stack.vpc_id

  tags = {
    Name    = "ec2_pool"
    Project = "cloudx"
  }
}

resource "aws_security_group_rule" "ec2_pool_ingress_bastion" {
  description              = "Allows SSH from Bastion"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "ec2_pool_ingress_vpc" {
  description       = "Allows traffic from Ghost VPC"
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [module.network_stack.vpc_cidr]
  security_group_id = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "ec2_pool_ingress_alb" {
  description              = "Allows traffic from ALB"
  type                     = "ingress"
  from_port                = 2368
  to_port                  = 2368
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2_pool.id
}

resource "aws_security_group_rule" "ec2_pool_egress_anywhere" {
  description       = "Allows traffic to anywhere"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_pool.id
}

### ALB ###

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allows access to ALB"
  vpc_id      = module.network_stack.vpc_id

  tags = {
    Name    = "alb"
    Project = "cloudx"
  }
}

resource "aws_security_group_rule" "alb_ingress_myip" {
  description       = "Allows traffic from my IP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_ec2_pool" {
  description              = "Allows traffic to EC2 pool"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ec2_pool.id
  security_group_id        = aws_security_group.alb.id
}

### EFS ###

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "Defines access to EFS mount points"
  vpc_id      = module.network_stack.vpc_id

  tags = {
    Name    = "efs"
    Project = "cloudx"
  }
}

resource "aws_security_group_rule" "efs_ingress_ec2_pool" {
  description              = "Allows access from EC2 pool"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_pool.id
  security_group_id        = aws_security_group.efs.id
}

resource "aws_security_group_rule" "efs_egress_vpc" {
  description       = "Allows traffic to Ghost VPC"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [module.network_stack.vpc_cidr]
  security_group_id = aws_security_group.efs.id
}

# INFO: Create SSH key pair

resource "aws_key_pair" "ghost" {
  key_name   = "ghost-ec2-pool"
  public_key = var.ssh_public_key

  tags = {
    Name    = "ghost-ec2-pool"
    Project = "cloudx"
  }
}

# INFO: Create IAM role

resource "aws_iam_role" "ghost" {
  name = "ghost_app_role"

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
    Name    = "ghost_app_role"
    Project = "cloudx"
  }
}

resource "aws_iam_policy" "ghost" {
  name        = "ghost_app"
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
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  tags = {
    Name    = "ghost_app"
    Project = "cloudx"
  }
}

resource "aws_iam_role_policy_attachment" "ghost" {
  role       = aws_iam_role.ghost.name
  policy_arn = aws_iam_policy.ghost.arn
}

resource "aws_iam_instance_profile" "ghost" {
  name = "ghost_app_profile"
  role = aws_iam_role.ghost.name
}

# INFO: Create elastic file system

resource "aws_efs_file_system" "ghost" {
  tags = {
    Name    = "ghost_content"
    Project = "cloudx"
  }
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.ghost.id
  subnet_id       = module.network_stack.subnet_a_id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.ghost.id
  subnet_id       = module.network_stack.subnet_b_id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "c" {
  file_system_id  = aws_efs_file_system.ghost.id
  subnet_id       = module.network_stack.subnet_c_id
  security_groups = [aws_security_group.efs.id]
}

# INFO: Create application load balancer

module "load_balancer" {
  source = "./modules/load_balancer"

  security_groups = [aws_security_group.alb.id]
  subnets         = [module.network_stack.subnet_a_id, module.network_stack.subnet_b_id, module.network_stack.subnet_c_id]
  vpc_id          = module.network_stack.vpc_id
}

# INFO: Create launch template

resource "aws_launch_template" "ghost" {
  name                   = "ghost"
  image_id               = "ami-026b57f3c383c2eec"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_pool.id]
  key_name               = aws_key_pair.ghost.key_name
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.ghost.arn
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "ghost"
      Project = "cloudx"
    }
  }

  user_data = base64encode(templatefile("${path.module}/setupGhost.sh", {
    lb_dns_name = module.load_balancer.lb_dns_name
  }))
}

# INFO: Create auto-scaling group

module "auto_scaling_group" {
  source = "./modules/auto_scaling_group"

  vpc_zone_identifier = [
    module.network_stack.subnet_a_id,
    module.network_stack.subnet_b_id,
    module.network_stack.subnet_c_id
  ]
  launch_template_id  = aws_launch_template.ghost.id
  lb_target_group_arn = module.load_balancer.lb_target_group_arn
}

# INFO: Create bastion

module "bastion" {
  source = "./modules/bastion"

  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = aws_key_pair.ghost.key_name
  subnet_id              = module.network_stack.subnet_a_id
}

# TODO: modularize TF code
