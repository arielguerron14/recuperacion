#!/bin/bash
set -e

# Basic bootstrap for Amazon Linux 2: install Docker and Git, clone repo, build and run container
yum update -y
amazon-linux-extras install -y docker
yum install -y git
systemctl enable --now docker

# allow ec2-user to use docker (may require re-login; we run docker as root below)
usermod -a -G docker ec2-user || true

sleep 5

cd /home/ec2-user

REPO_URL="${repo_url}"

if [ ! -d app ]; then
  sudo -u ec2-user git clone "${REPO_URL}" app || true
else
  cd app || exit 0
  sudo -u ec2-user git pull || true
  cd ..
fi

cd app || exit 0

# Build the Docker image
docker build -t proyecto-hola-mundo:latest . || true

# Stop old container if exists
docker rm -f proyecto-hola-mundo || true

# Run container mapping host 80 to container 3000 and restart automatically
docker run -d --name proyecto-hola-mundo -p 80:3000 --restart unless-stopped proyecto-hola-mundo:latest || true
