resource "aws_security_group" "this" {
  name        = var.bastion_sg_name
  description = "Allows access to bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name    = var.bastion_sg_name
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_host_ip" {
  description       = "Allows SSH from host IP"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.this.id
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

resource "aws_instance" "this" {
  instance_type               = "t2.micro"
  ami                         = "ami-026b57f3c383c2eec"
  associate_public_ip_address = true
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id

  tags = {
    Name    = var.bastion_name
    Project = var.project
  }
}
