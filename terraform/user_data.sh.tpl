#!/bin/bash
yum update -y

amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

yum install -y git

# Esperar a que Docker esté listo (CRÍTICO)
sleep 60

cd /home/ec2-user
git clone ${repo_url}
cd recuperacion

docker build -t hola-app .

docker stop hola-app || true
docker rm hola-app || true

docker run -d \
  --name hola-app \
  -p 80:3000 \
  --restart always \
  hola-app
