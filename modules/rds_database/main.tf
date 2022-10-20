resource "aws_security_group" "this" {
  name        = var.rds_sg_name
  description = "Defines access to DB"
  vpc_id      = var.vpc_id

  tags = {
    Name    = var.rds_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_ec2_pool" {
  description              = "Allows access from EC2 pool"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.ec2_pool_sg_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_db_subnet_group" "this" {
  name        = var.db_subnet_grp_name
  description = "Database subnet group"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name    = var.db_subnet_grp_name
    Project = var.project
  }
}

resource "aws_db_instance" "this" {
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  tags = {
    Name    = var.db_name
    Project = var.project
  }
}

resource "aws_ssm_parameter" "this" {
  name        = "/${var.db_username}/dbpasswd"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Name    = var.ssm_parameter_name
    Project = var.project
  }
}
