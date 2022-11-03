#!/bin/bash -xe

exec > >(tee /var/log/cloud-init-output.log|logger -t user-data -s 2>/dev/console) 2>&1

SSM_DB_PASSWORD="/${db_username}/dbpasswd"
REGION=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
DB_PASSWORD=$(aws ssm get-parameter --name $SSM_DB_PASSWORD --query Parameter.Value --with-decryption --region $REGION --output text)

wget -P /tmp https://rpm.nodesource.com/pub_14.x/el/9/x86_64/nodejs-14.21.0-1nodesource.x86_64.rpm
sudo yum install /tmp/nodejs-14.21.0-1nodesource.x86_64.rpm -y
npm install ghost-cli@latest -g

adduser ghost_user
usermod -aG wheel ghost_user
cd /home/ghost_user/

sudo -u ghost_user ghost install ${ghost_version} local

cat << EOF > config.development.json

{
  "url": "http://${lb_dns_name}",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "mysql",
    "connection": {
        "host": "${db_url}",
        "port": 3306,
        "user": "${db_username}",
        "password": "$DB_PASSWORD",
        "database": "${db_name}"
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
    "contentPath": "/home/ghost_user/content"
  }
}
EOF

sudo -u ghost_user ghost stop
sudo -u ghost_user ghost start
