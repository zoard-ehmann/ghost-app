# Common
project = "cloudx"

# Network stack
vpc_name         = "cloudx"
subnet_a_name    = "public_a"
subnet_b_name    = "public_b"
subnet_c_name    = "public_c"
subnet_db_a_name = "private_db_a"
subnet_db_b_name = "private_db_b"
subnet_db_c_name = "private_db_c"
igw_name         = "cloudx-igw"
public_rt_name   = "public_rt"
private_rt_name  = "private_rt"

# SSH key-pair
key_pair_name = "ghost-ec2-pool"

# IAM
iam_role_name    = "ghost_app_role"
iam_policy_name  = "ghost_app"
iam_profile_name = "ghost_app_profile"

# EFS
efs_sg_name = "efs"
efs_name    = "ghost_content"

# Load balancer
alb_sg_name   = "alb"
alb_name      = "ghost-alb"
tg_name       = "ghost-ec2"
listener_name = "ghost-alb-listener"

# Auto-scaling group
ec2_pool_sg_name     = "ec2_pool"
launch_template_name = "ghost"
asg_instance_name    = "ghost-instance"

# Bastion
bastion_sg_name = "bastion"
bastion_name    = "bastion"
