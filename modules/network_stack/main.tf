### VPC ###

resource "aws_vpc" "this" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = var.vpc_name
    Project = var.project
  }
}

### SUBNETS ###

resource "aws_subnet" "a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = var.subnet_a_name
    Project = var.project
  }
}

resource "aws_subnet" "b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name    = var.subnet_b_name
    Project = var.project
  }
}

resource "aws_subnet" "c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name    = var.subnet_c_name
    Project = var.project
  }
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.20.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = var.subnet_db_a_name
    Project = var.project
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = var.subnet_db_b_name
    Project = var.project
  }
}

resource "aws_subnet" "db_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.22.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name    = var.subnet_db_c_name
    Project = var.project
  }
}

resource "aws_subnet" "ecs_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name    = var.subnet_ecs_a_name
    Project = var.project
  }
}

resource "aws_subnet" "ecs_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name    = var.subnet_ecs_b_name
    Project = var.project
  }
}

resource "aws_subnet" "ecs_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.10.12.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name    = var.subnet_ecs_c_name
    Project = var.project
  }
}

### IGW ###

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = var.igw_name
    Project = var.project
  }
}

### ROUTE TABLE ###

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name    = var.public_rt_name
    Project = var.project
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = var.private_rt_name
    Project = var.project
  }
}

resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_c" {
  subnet_id      = aws_subnet.db_c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "ecs_a" {
  subnet_id      = aws_subnet.ecs_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "ecs_b" {
  subnet_id      = aws_subnet.ecs_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "ecs_c" {
  subnet_id      = aws_subnet.ecs_c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "this" {
  name        = var.vpc_sg_name
  description = "Configures VPC endpoint access"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name    = var.vpc_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_https_vpc" {
  description       = "Allows HTTPS access from VPC"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_http_vpc" {
  description       = "Allows HTTP access from VPC"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.this.id
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.this.id]

  tags = {
    Project = var.project
  }
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.this.id]

  tags = {
    Project = var.project
  }
}

resource "aws_vpc_endpoint" "efs" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.elasticfilesystem"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.this.id]

  tags = {
    Project = var.project
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Project = var.project
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.this.id]

  tags = {
    Project = var.project
  }
}

# HELP: https://dev.to/danquack/private-fargate-deployment-with-vpc-endpoints-1h0p
