# Get default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = var.availability_zones
  }
}

##########################
# Security Groups
##########################

resource "aws_security_group" "ec2_sg" {
  name        = "hola-ec2-sg"
  description = "Security Group for EC2: allow SSH and HTTP 3000"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP 3000 from anywhere"
    from_port   = 3000
    to_port     = 3000
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

  tags = {
    Name = "hola-ec2-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "hola-alb-sg"
  description = "Security Group for ALB: allow HTTP 80"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from anywhere"
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

  tags = {
    Name = "hola-alb-sg"
  }
}

##########################
# EC2 Instance
##########################

resource "aws_instance" "hola" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "hola-instance"
  }
}

##########################
# Application Load Balancer
##########################

resource "aws_lb" "hola" {
  name               = "hola-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default_public.ids

  enable_deletion_protection = false

  tags = {
    Name = "hola-alb"
  }
}

##########################
# Target Group
##########################

resource "aws_lb_target_group" "hola" {
  name     = "hola-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "hola-tg"
  }
}

# Register EC2 instance with Target Group
resource "aws_lb_target_group_attachment" "hola" {
  target_group_arn = aws_lb_target_group.hola.arn
  target_id        = aws_instance.hola.id
  port             = 3000
}

##########################
# ALB Listener
##########################

resource "aws_lb_listener" "hola" {
  load_balancer_arn = aws_lb.hola.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hola.arn
  }
}

##########################
# Outputs
##########################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.hola.dns_name
}

output "alb_url" {
  description = "URL to access the application via the ALB"
  value       = "http://${aws_lb.hola.dns_name}"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.hola.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.hola.public_ip
}
