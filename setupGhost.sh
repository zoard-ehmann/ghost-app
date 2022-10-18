#!/bin/bash -xe

exec > >(tee /var/log/cloud-init-output.log|logger -t user-data -s 2>/dev/console) 2>&1

REGION=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
EFS_ID=$(aws efs describe-file-systems --query 'FileSystems[?Name==`ghost_content`].FileSystemId' --region $REGION --output text)

### Install pre-reqs
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
yum install -y nodejs amazon-efs-utils
npm install ghost-cli@latest -g

adduser ghost_user
usermod -aG wheel ghost_user
cd /home/ghost_user/

sudo -u ghost_user ghost install local

### EFS mount
mkdir -p /home/ghost_user/ghost/content
mount -t efs -o tls $EFS_ID:/ /home/ghost_user/ghost/content

cat << EOF > config.development.json

{
  "url": "http://${lb_dns_name}",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "sqlite3",
    "connection": {
      "filename": "/home/ghost_user/ghost/content/data/ghost-local.db"
    }
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": [
      "file",
      "stdout"
    ]
  },
  "process": "local",
  "paths": {
    "contentPath": "/home/ghost_user/ghost/content"
  }
}
EOF

sudo -u ghost_user ghost stop
sudo -u ghost_user ghost start
