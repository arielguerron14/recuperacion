#!/bin/bash
set -e

yum update -y

amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

yum install -y git

# Esperar a que Docker esté listo
sleep 60

cd /home/ec2-user

if [ ! -d recuperacion ]; then
  git clone ${repo_url}
else
  cd recuperacion
  git pull
  cd ..
fi

cd recuperacion

docker build -t hola-app .

docker rm -f hola-app || true

docker run -d \
  --name hola-app \
  -p 80:3000 \
  --restart always \
  hola-app
