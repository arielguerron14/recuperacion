# ============================================================================
# TERRAFORM OUTPUTS
# ============================================================================
# This file defines all output values that will be displayed after apply
# ============================================================================

# ============================================================================
# VPC AND NETWORKING OUTPUTS
# ============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of all public subnets"
  value       = aws_subnet.public[*].id
}

# ============================================================================
# LOAD BALANCER OUTPUTS
# ============================================================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer (for Route 53)"
  value       = aws_lb.main.zone_id
}

# ============================================================================
# TARGET GROUP OUTPUTS
# ============================================================================

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_name" {
  description = "Name of the Target Group"
  value       = aws_lb_target_group.app.name
}

# ============================================================================
# AUTO SCALING GROUP OUTPUTS
# ============================================================================

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.id
}

output "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.min_size
}

output "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.max_size
}

output "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.desired_capacity
}

# ============================================================================
# EC2 INSTANCES OUTPUTS
# ============================================================================

output "instance_ids" {
  description = "IDs of all EC2 instances launched by the ASG"
  value       = data.aws_instances.asg_instances.ids
}

output "instance_public_ips" {
  description = "Public IP addresses of all EC2 instances"
  value       = data.aws_instances.asg_instances.public_ips
}

output "instance_private_ips" {
  description = "Private IP addresses of all EC2 instances"
  value       = data.aws_instances.asg_instances.private_ips
}

# ============================================================================
# APPLICATION ACCESS OUTPUTS
# ============================================================================

output "application_url" {
  description = "URL to access the application via the ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "docker_health_check_endpoint" {
  description = "Health check endpoint used by the ALB"
  value       = "http://${aws_lb.main.dns_name}/"
}

# ============================================================================
# SECURITY GROUPS OUTPUTS
# ============================================================================

output "alb_security_group_id" {
  description = "Security Group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "Security Group ID for EC2 instances"
  value       = aws_security_group.ec2.id
}

# ============================================================================
# LAUNCH TEMPLATE OUTPUTS
# ============================================================================

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest version number of the Launch Template"
  value       = aws_launch_template.app.latest_version_number
}

# ============================================================================
# AMI OUTPUTS
# ============================================================================

output "ami_id" {
  description = "ID of the Amazon Linux 2 AMI used by instances"
  value       = data.aws_ami.amazon_linux_2.id
}

output "ami_name" {
  description = "Name of the Amazon Linux 2 AMI used by instances"
  value       = data.aws_ami.amazon_linux_2.name
}

# ============================================================================
# DEPLOYMENT INFORMATION
# ============================================================================

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    app_name              = var.app_name
    region                = var.region
    instance_type         = var.instance_type
    min_instances         = var.asg_min_size
    max_instances         = var.asg_max_size
    current_instances     = var.asg_desired_capacity
    container_port        = var.container_port
    github_repository     = var.github_repo_url
    alb_dns               = aws_lb.main.dns_name
    application_url       = "http://${aws_lb.main.dns_name}"
  }
}
