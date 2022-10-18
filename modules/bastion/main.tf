resource "aws_instance" "this" {
  instance_type               = "t2.micro"
  ami                         = "ami-026b57f3c383c2eec"
  associate_public_ip_address = true
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id

  tags = {
    Name    = "bastion"
    Project = "cloudx"
  }
}
