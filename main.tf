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

### EFS ###

variable "efs_sg_name" {
  description = "Elastic file system security group name"
  type        = string
}

### LOAD BALANCER ###

variable "alb_sg_name" {
  description = "Load balancer security group name"
  type        = string
}

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

variable "ec2_pool_sg_name" {
  description = "EC2 pool security group name"
  type        = string
}

variable "launch_template_name" {
  description = "Name of the launch template"
  type        = string
}

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

module "efs" {
  source = "./modules/efs"

  vpc_id             = module.network_stack.vpc_id
  ec2_pool_sg_id     = module.auto_scaling_group.sg_id
  egress_cidr_blocks = [module.network_stack.vpc_cidr]

  subnet_a_id = module.network_stack.subnet_a_id
  subnet_b_id = module.network_stack.subnet_b_id
  subnet_c_id = module.network_stack.subnet_c_id

  project     = var.project
  efs_sg_name = var.efs_sg_name
  efs_name    = var.efs_name
}

# INFO: Create application load balancer

module "load_balancer" {
  source = "./modules/load_balancer"

  ingress_cidr_blocks = ["${chomp(data.http.host_ip.response_body)}/32"]
  ec2_pool_sg_id      = module.auto_scaling_group.sg_id

  subnets = [
    module.network_stack.subnet_a_id,
    module.network_stack.subnet_b_id,
    module.network_stack.subnet_c_id
  ]
  vpc_id = module.network_stack.vpc_id

  project       = var.project
  alb_sg_name   = var.alb_sg_name
  alb_name      = var.alb_name
  tg_name       = var.tg_name
  listener_name = var.listener_name
}

# INFO: Create auto-scaling group

module "auto_scaling_group" {
  source = "./modules/auto_scaling_group"

  vpc_id              = module.network_stack.vpc_id
  bastion_sg_id       = module.bastion.sg_id
  ingress_cidr_blocks = [module.network_stack.vpc_cidr]
  alb_sg_id           = aws_security_group.alb.id

  key_name        = aws_key_pair.ghost.key_name
  iam_profile_arn = aws_iam_instance_profile.ghost.arn
  lb_dns_name     = module.load_balancer.lb_dns_name

  vpc_zone_identifier = [
    module.network_stack.subnet_a_id,
    module.network_stack.subnet_b_id,
    module.network_stack.subnet_c_id
  ]
  lb_target_group_arn = module.load_balancer.lb_target_group_arn

  project              = var.project
  ec2_pool_sg_name     = var.ec2_pool_sg_name
  launch_template_name = var.launch_template_name
  asg_instance_name    = var.asg_instance_name
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
