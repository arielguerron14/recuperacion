terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Launch Template: defines instance configuration
resource "aws_launch_template" "app" {
  name_prefix   = "hola-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = [var.ec2_sg_id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", { repo_url = var.repo_url }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "hola-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group: launches and manages EC2 instances
resource "aws_autoscaling_group" "app" {
  name            = "hola-asg"
  max_size        = var.max_size
  min_size        = var.min_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.tg_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "hola-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Data source to get instance IPs from ASG
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = ["hola-instance"]
  }

  depends_on = [aws_autoscaling_group.app]
}
