# INFO: Set up variables

### COMMON ###

variable "ssh_public_key" {
  description = "SSH public key to connect to the instances"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

### NETWORK STACK ###

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

### SECURITY GROUP ###

variable "ec2_pool_sg_name" {
  description = "EC2 pool security group name"
  type        = string
}

variable "alb_sg_name" {
  description = "Load balancer security group name"
  type        = string
}

variable "efs_sg_name" {
  description = "Elastic file system security group name"
  type        = string
}

### LOAD BALANCER ###

variable "alb_name" {
  description = "Name of the application load balancer"
  type        = string
}

variable "tg_name" {
  description = "Name of the target group"
  type        = string
}

variable "listener_name" {
  description = "Name of the listener"
  type        = string
}

### AUTO-SCALING GROUP ###

variable "asg_instance_name" {
  description = "Name of the EC2 instances within ASG"
  type        = string
}

### BASTION ###

variable "bastion_sg_name" {
  description = "Bastion security group name"
  type        = string
}

variable "bastion_name" {
  description = "Name of the bastion instance"
  type        = string
}

# INFO: Set up data sources

data "http" "host_ip" {
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
  source_security_group_id = module.bastion.sg_id
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

resource "aws_security_group_rule" "alb_ingress_host_ip" {
  description       = "Allows traffic from host IP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.host_ip.response_body)}/32"]
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

  project       = var.project
  alb_name      = var.alb_name
  tg_name       = var.tg_name
  listener_name = var.listener_name
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

  project           = var.project
  asg_instance_name = var.asg_instance_name
}

# INFO: Create bastion

module "bastion" {
  source = "./modules/bastion"

  vpc_id              = module.network_stack.vpc_id
  ingress_cidr_blocks = ["${chomp(data.http.host_ip.response_body)}/32"]

  vpc_security_group_ids = [module.bastion.sg_id]
  key_name               = aws_key_pair.ghost.key_name
  subnet_id              = module.network_stack.subnet_a_id

  project         = var.project
  bastion_sg_name = var.bastion_sg_name
  bastion_name    = var.bastion_name
}

# TODO: modularize TF code
