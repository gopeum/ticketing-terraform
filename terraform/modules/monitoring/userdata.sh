#!/bin/bash
set -e

yum update -y
yum install -y docker git

systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Docker Compose 설치
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# repo clone
cd /opt
git clone https://github.com/gopeum/ticketing-terraform

cd /opt/infra-repo/monitoring-config

# 실행
docker-compose up -d