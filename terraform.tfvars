# Common
project = "cloudx"

# Network stack
vpc_name      = "cloudx"
subnet_a_name = "public_a"
subnet_b_name = "public_b"
subnet_c_name = "public_c"
igw_name      = "cloudx-igw"
rt_name       = "public_rt"

# Security groups
ec2_pool_sg_name = "ec2_pool"
alb_sg_name      = "alb"
efs_sg_name      = "efs"

# Load balancer
alb_name      = "ghost-alb"
tg_name       = "ghost-ec2"
listener_name = "ghost-alb-listener"

# Auto-scaling group
asg_instance_name = "ghost-instance"

# Bastion
bastion_sg_name = "bastion"
bastion_name    = "bastion"
