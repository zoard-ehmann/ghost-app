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
  vpc_security_group_ids      = [aws_security_group.this.id]
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  user_data_replace_on_change = true

  provisioner "file" {
    source      = "/home/${var.host_username}/.ssh/${var.key_pair_name}"
    destination = "/home/ec2-user/.ssh/${var.key_pair_name}"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/${var.host_username}/.ssh/${var.key_pair_name}")
      host        = self.public_ip
    }
  }

  user_data = <<EOF
#!/bin/bash -xe

chmod 400 "/home/ec2-user/.ssh/${var.key_pair_name}"
EOF

  tags = {
    Name    = var.bastion_name
    Project = var.project
  }
}
