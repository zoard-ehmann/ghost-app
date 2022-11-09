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

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ghost_version" {
  description = "Version of Ghost app"
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

variable "subnet_ecs_a_name" {
  description = "Name of ECS subnet A"
  type        = string
}

variable "subnet_ecs_b_name" {
  description = "Name of  ECS subnet B"
  type        = string
}

variable "subnet_ecs_c_name" {
  description = "Name of  ECS subnet C"
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

variable "vpc_sg_name" {
  description = "VPC security group name"
  type        = string
}

### SSH KEY-PAIR ###

variable "key_pair_name" {
  description = "Name of the SSH key-pair"
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

variable "ec2_tg_name" {
  description = "Name of the EC2 target group"
  type        = string
}

variable "fargate_tg_name" {
  description = "Name of the Fargate target group"
  type        = string
}

variable "listener_name" {
  description = "Name of the listener"
  type        = string
}

### AUTO-SCALING GROUP ###

variable "asg_iam_role_name" {
  description = "Name of the ASG IAM role"
  type        = string
}

variable "asg_iam_policy_name" {
  description = "Name of the ASG IAM policy"
  type        = string
}

variable "asg_iam_profile_name" {
  description = "Name of the ASG IAM instance profile"
  type        = string
}

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

variable "asg_name" {
  description = "Name of the ASG"
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

variable "ssm_parameter_name" {
  description = "Name of SSM parameter"
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

variable "db_username" {
  description = "Username of DB user"
  type        = string
}

variable "db_password" {
  description = "Password of DB user"
  type        = string
}

### ECS ###

variable "ecs_sg_name" {
  description = "Fargate pool security group name"
  type        = string
}

variable "ecr_name" {
  description = "Name of ECR"
  type        = string
}

variable "ecs_iam_role_name" {
  description = "Name of the ECS IAM role"
  type        = string
}

variable "ecs_iam_policy_name" {
  description = "Name of the ECS IAM policy"
  type        = string
}

variable "ecs_iam_profile_name" {
  description = "Name of the ECS IAM instance profile"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
  type        = string
}

variable "ecs_task_def_name" {
  description = "Name of ECS task definition"
  type        = string
}

variable "volume_name" {
  description = "Name of volume"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "image_name" {
  description = "Name of the app image"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
}

### DASHBOARD ###

variable "dashboard_iam_policy_name" {
  description = "Name of the CloudWatch Dashboard IAM policy"
  type        = string
}

variable "cw_dashboard_name" {
  description = "Name of CloudWatch Dashboard"
  type        = string
}

# INFO: Set outputs

output "lb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.load_balancer.lb_dns_name
}

output "bastion_dns" {
  description = "DNS of the bastion"
  value       = module.bastion.bastion_dns
}

# INFO: Set up data sources

data "http" "host_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_region" "current" {}

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
  region  = var.region
}


# INFO: Create network stack

module "network_stack" {
  source = "./modules/network_stack"

  region = data.aws_region.current.name

  project           = var.project
  vpc_name          = var.vpc_name
  subnet_a_name     = var.subnet_a_name
  subnet_b_name     = var.subnet_b_name
  subnet_c_name     = var.subnet_c_name
  subnet_db_a_name  = var.subnet_db_a_name
  subnet_db_b_name  = var.subnet_db_b_name
  subnet_db_c_name  = var.subnet_db_c_name
  subnet_ecs_a_name = var.subnet_ecs_a_name
  subnet_ecs_b_name = var.subnet_ecs_b_name
  subnet_ecs_c_name = var.subnet_ecs_c_name
  igw_name          = var.igw_name
  public_rt_name    = var.public_rt_name
  private_rt_name   = var.private_rt_name
  vpc_sg_name       = var.vpc_sg_name
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

# INFO: Create elastic file system

module "efs" {
  source = "./modules/efs"

  vpc_id             = module.network_stack.vpc_id
  ec2_pool_sg_id     = module.auto_scaling_group.sg_id
  fargate_pool_sg_id = module.ecs_fargate.sg_id
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
  fargate_pool_sg_id  = module.ecs_fargate.sg_id

  subnets = [
    module.network_stack.subnet_a_id,
    module.network_stack.subnet_b_id,
    module.network_stack.subnet_c_id
  ]
  vpc_id = module.network_stack.vpc_id

  project         = var.project
  alb_sg_name     = var.alb_sg_name
  alb_name        = var.alb_name
  ec2_tg_name     = var.ec2_tg_name
  fargate_tg_name = var.fargate_tg_name
  listener_name   = var.listener_name
}

# INFO: Create auto-scaling group

module "auto_scaling_group" {
  source = "./modules/auto_scaling_group"

  dashboard_iam_policy_arn = module.dashboard.dashboard_iam_policy_arn

  vpc_id              = module.network_stack.vpc_id
  bastion_sg_id       = module.bastion.sg_id
  ingress_cidr_blocks = [module.network_stack.vpc_cidr]
  alb_sg_id           = module.load_balancer.sg_id

  key_name      = aws_key_pair.ghost.key_name
  lb_dns_name   = module.load_balancer.lb_dns_name
  db_url        = module.rds_database.db_url
  db_username   = var.db_username
  db_name       = var.db_name
  ghost_version = var.ghost_version

  vpc_zone_identifier = [
    module.network_stack.subnet_a_id,
    module.network_stack.subnet_b_id,
    module.network_stack.subnet_c_id
  ]
  ec2_lb_target_group_arn = module.load_balancer.ec2_lb_target_group_arn

  project              = var.project
  asg_iam_role_name    = var.asg_iam_role_name
  asg_iam_policy_name  = var.asg_iam_policy_name
  asg_iam_profile_name = var.asg_iam_profile_name
  ec2_pool_sg_name     = var.ec2_pool_sg_name
  launch_template_name = var.launch_template_name
  asg_instance_name    = var.asg_instance_name
  asg_name             = var.asg_name
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

  vpc_id             = module.network_stack.vpc_id
  ec2_pool_sg_id     = module.auto_scaling_group.sg_id
  fargate_pool_sg_id = module.ecs_fargate.sg_id

  db_subnet_ids = [
    module.network_stack.subnet_db_a_id,
    module.network_stack.subnet_db_b_id,
    module.network_stack.subnet_db_c_id
  ]

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  project            = var.project
  rds_sg_name        = var.rds_sg_name
  db_subnet_grp_name = var.db_subnet_grp_name
  ssm_parameter_name = var.ssm_parameter_name
}

# INFO: Create ECS Fargate

module "ecs_fargate" {
  source = "./modules/ecs_fargate"

  vpc_id                      = module.network_stack.vpc_id
  efs_sg_id                   = module.efs.sg_id
  alb_sg_id                   = module.load_balancer.sg_id
  efs_id                      = module.efs.efs_id
  ghost_version               = var.ghost_version
  db_url                      = module.rds_database.db_url
  db_username                 = var.db_username
  db_password                 = var.db_password
  db_name                     = var.db_name
  fargate_lb_target_group_arn = module.load_balancer.fargate_lb_target_group_arn
  ecs_subnets = [
    module.network_stack.subnet_ecs_a_id,
    module.network_stack.subnet_ecs_b_id,
    module.network_stack.subnet_ecs_c_id
  ]

  dashboard_iam_policy_arn = module.dashboard.dashboard_iam_policy_arn

  project              = var.project
  ecs_sg_name          = var.ecs_sg_name
  ecr_name             = var.ecr_name
  ecs_iam_role_name    = var.ecs_iam_role_name
  ecs_iam_policy_name  = var.ecs_iam_policy_name
  ecs_iam_profile_name = var.ecs_iam_profile_name
  ecs_cluster_name     = var.ecs_cluster_name
  ecs_task_def_name    = var.ecs_task_def_name
  volume_name          = var.volume_name
  container_name       = var.container_name
  image_name           = var.image_name
  service_name         = var.service_name
}

module "dashboard" {
  source = "./modules/dashboard"

  dashboard_iam_policy_name = var.dashboard_iam_policy_name

  region           = var.region
  asg_name         = var.asg_name
  service_name     = var.service_name
  ecs_cluster_name = var.ecs_cluster_name
  efs_id           = module.efs.efs_id
  db_id            = module.rds_database.db_id

  project           = var.project
  cw_dashboard_name = var.cw_dashboard_name
}
