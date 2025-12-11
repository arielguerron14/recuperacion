terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
provider "aws" {
  region = var.region
}

##########################
# Variables
##########################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the existing VPC to use"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2 (e.g. ami-... )"
  type        = string
}

variable "github_repo" {
  description = "HTTPS GitHub repository URL to clone (e.g. https://github.com/owner/repo.git)"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR format used to allow SSH (e.g. 203.0.113.5/32)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

##########################
# Data sources (existing VPC/subnets)
##########################

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# We'll pick the first subnet for the EC2 (assumed public). For the ALB we use all subnets in the VPC.

##########################
# Security Groups
##########################

resource "aws_security_group" "alb_sg" {
  name        = "simple-web-alb-sg"
  description = "Security Group for ALB allowing HTTP"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "simple-web-ec2-sg"
  description = "Security Group for EC2: allow SSH from my IP and HTTP from ALB"
  vpc_id      = data.aws_vpc.existing.id

  # SSH from user's IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # We will allow HTTP from the ALB SG via a security group rule below

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow traffic from ALB SG to EC2 SG on port 80
resource "aws_security_group_rule" "allow_alb_to_ec2_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  description              = "Allow ALB to reach EC2 on HTTP"
}

##########################
# EC2 Instance
##########################

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnets.vpc_subnets.ids, 0)
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  # Simple user_data script to install Docker, clone repo, build and run container
  user_data = <<-EOF
              #!/bin/bash
              set -e
              yum update -y
              amazon-linux-extras install -y docker
              service docker start
              usermod -a -G docker ec2-user
              chmod 755 /home/ec2-user
              sudo -u ec2-user bash -c 'mkdir -p /home/ec2-user/app'
              cd /home/ec2-user
              sudo -u ec2-user git clone ${var.github_repo} app || (cd app && sudo -u ec2-user git pull)
              cd app
              # If there's a Dockerfile, build and run; otherwise try to run a Node image if defined
              if [ -f Dockerfile ]; then
                sudo -u ec2-user docker build -t webapp:latest .
                # stop any existing container and run new
                if sudo -u ec2-user docker ps -q --filter "name=simple_web_app" | grep -q .; then
                  sudo -u ec2-user docker rm -f simple_web_app || true
                fi
                sudo -u ec2-user docker run -d --name simple_web_app -p 80:3000 webapp:latest
              else
                # fallback: try to run npm start inside repo (require Node in repo) - best effort
                echo "No Dockerfile found. Please include a Dockerfile in the repo that exposes port 3000."
              fi
  EOF

  tags = {
    Name = "simple-web-instance"
  }
}

##########################
# Application Load Balancer
##########################

resource "aws_lb" "web_alb" {
  name               = "simple-web-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.vpc_subnets.ids
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false
  tags = {
    Name = "simple-web-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "simple-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Register the EC2 instance with the target group
resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}

##########################
# Outputs
##########################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

output "application_url" {
  description = "URL to access the application via the ALB"
  value       = "http://${aws_lb.web_alb.dns_name}"
}
