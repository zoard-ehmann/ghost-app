# INFO: Set up variables

variable "ssh_public_key" {
  description = "SSH public key to connect to the instances"
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

### VPC ###

resource "aws_vpc" "ghost" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "cloudx"
    Project = "cloudx"
  }
}

### SUBNETS ###

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.ghost.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name    = "public_a"
    Project = "cloudx"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.ghost.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name    = "public_b"
    Project = "cloudx"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.ghost.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name    = "public_c"
    Project = "cloudx"
  }
}

### IGW ###

resource "aws_internet_gateway" "ghost" {
  vpc_id = aws_vpc.ghost.id

  tags = {
    Name    = "cloudx-igw"
    Project = "cloudx"
  }
}

### ROUTE TABLE ###

resource "aws_route_table" "ghost" {
  vpc_id = aws_vpc.ghost.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ghost.id
  }

  tags = {
    Name    = "public_rt"
    Project = "cloudx"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.ghost.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.ghost.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.ghost.id
}

# INFO: Create security groups

### BASTION ###

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allows access to bastion"
  vpc_id      = aws_vpc.ghost.id

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
  vpc_id      = aws_vpc.ghost.id

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
  cidr_blocks       = [aws_vpc.ghost.cidr_block]
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
  vpc_id      = aws_vpc.ghost.id

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
  vpc_id      = aws_vpc.ghost.id

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
  cidr_blocks       = [aws_vpc.ghost.cidr_block]
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

# INFO: Create elastic file system

resource "aws_efs_file_system" "ghost" {
  tags = {
    Name    = "ghost_content"
    Project = "cloudx"
  }
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.ghost.id
  subnet_id       = aws_subnet.public_a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.ghost.id
  subnet_id       = aws_subnet.public_b.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "c" {
  file_system_id  = aws_efs_file_system.ghost.id
  subnet_id       = aws_subnet.public_c.id
  security_groups = [aws_security_group.efs.id]
}
