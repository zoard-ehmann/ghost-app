# INFO: Set up variables

### COMMON ###

variable "ssh_public_key" {
  description = "SSH public key to connect to the instances"
  type        = string
}

variable "host_username" {
  description = "Username on the host machine (helps to locate SSH private key)"
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

variable "subnet_db_a_name" {
  description = "Name of DB subnet A"
  type        = string
}

variable "subnet_db_b_name" {
  description = "Name of DB subnet B"
  type        = string
}

variable "subnet_db_c_name" {
  description = "Name of DB subnet C"
  type        = string
}

variable "igw_name" {
  description = "Name of internet gateway"
  type        = string
}

variable "public_rt_name" {
  description = "Name of public route table"
  type        = string
}

variable "private_rt_name" {
  description = "Name of private route table"
  type        = string
}

### SSH KEY-PAIR ###

variable "key_pair_name" {
  description = "Name of the SSH key-pair"
  type        = string
}

### IAM ###

variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "iam_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

### EFS ###

variable "efs_sg_name" {
  description = "Elastic file system security group name"
  type        = string
}

variable "efs_name" {
  description = "Name of elastic file system"
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

### RDS DB ###

variable "rds_sg_name" {
  description = "RDS security group name"
  type        = string
}

variable "db_subnet_grp_name" {
  description = "Name of DB subnet group"
  type        = string
}

variable "db_name" {
  description = "Name of DB"
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

  project        = var.project
  vpc_name       = var.vpc_name
  subnet_a_name  = var.subnet_a_name
  subnet_b_name  = var.subnet_b_name
  subnet_c_name  = var.subnet_c_name
  igw_name       = var.igw_name
  public_rt_name = var.public_rt_name
}

# INFO: Create SSH key pair

resource "aws_key_pair" "ghost" {
  key_name   = var.key_pair_name
  public_key = var.ssh_public_key

  tags = {
    Name    = var.key_pair_name
    Project = var.project
  }
}

# INFO: Create IAM role

module "iam" {
  source = "./modules/iam"

  project          = var.project
  iam_role_name    = var.iam_role_name
  iam_policy_name  = var.iam_policy_name
  iam_profile_name = var.iam_profile_name
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
  alb_sg_id           = module.load_balancer.sg_id

  key_name        = aws_key_pair.ghost.key_name
  iam_profile_arn = module.iam.iam_profile_arn
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

  key_name      = aws_key_pair.ghost.key_name
  subnet_id     = module.network_stack.subnet_a_id
  host_username = var.host_username
  key_pair_name = var.key_pair_name

  project         = var.project
  bastion_sg_name = var.bastion_sg_name
  bastion_name    = var.bastion_name
}

# INFO: Create database on RDS

module "rds_database" {
  source = "./modules/rds_database"

  vpc_id         = module.network_stack.vpc_id
  ec2_pool_sg_id = module.auto_scaling_group.sg_id

  db_subnet_ids = [
    module.network_stack.subnet_db_a_id,
    module.network_stack.subnet_db_b_id,
    module.network_stack.subnet_db_c_id
  ]

  db_name = var.db_name

  project            = var.project
  rds_sg_name        = var.rds_sg_name
  db_subnet_grp_name = var.db_subnet_grp_name
}
