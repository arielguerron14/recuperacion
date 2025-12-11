#!/bin/bash
# ============================================================================
# USER DATA SCRIPT FOR EC2 INSTANCES
# ============================================================================
# This script runs on EC2 instance startup to:
# - Update the system
# - Install Docker and Git
# - Clone the GitHub repository
# - Build the Docker image
# - Run the Docker container
# ============================================================================

set -e

echo "=== Starting EC2 User Data Script ==="
echo "Timestamp: $(date)"

# ============================================================================
# SYSTEM UPDATES
# ============================================================================

echo "[1/7] Updating system packages..."
yum update -y

# ============================================================================
# DOCKER INSTALLATION
# ============================================================================

echo "[2/7] Installing Docker..."
amazon-linux-extras install docker -y

echo "[3/7] Starting Docker daemon..."
systemctl start docker
systemctl enable docker

# Wait for Docker daemon to be fully ready
echo "[4/7] Waiting for Docker daemon to be ready..."
sleep 60

# Verify Docker is running
docker --version
echo "Docker daemon is ready"

# ============================================================================
# GIT INSTALLATION
# ============================================================================

echo "[5/7] Installing Git..."
yum install -y git

# ============================================================================
# CLONE REPOSITORY AND BUILD DOCKER IMAGE
# ============================================================================

echo "[6/7] Cloning GitHub repository..."
cd /home/ec2-user

# Clone the repository
git clone ${github_repo} app-repo

# Navigate to the repository directory
cd app-repo

echo "Repository contents:"
ls -la

# ============================================================================
# BUILD AND RUN DOCKER CONTAINER
# ============================================================================

echo "[7/7] Building Docker image..."
docker build -t ${app_name}-image .

echo "Built Docker image successfully"
docker images | grep ${app_name}

# Remove any existing container with the same name
docker rm -f ${app_name}-container || true

echo "Running Docker container..."
docker run -d \
  --name ${app_name}-container \
  -p 80:${container_port} \
  --restart always \
  ${app_name}-image

echo "Docker container started successfully"

# Verify the container is running
sleep 10
docker ps | grep ${app_name}

echo "=== EC2 User Data Script Completed Successfully ==="
echo "Application is running in Docker container on port 80 (mapped to container port ${container_port})"
echo "Timestamp: $(date)"
