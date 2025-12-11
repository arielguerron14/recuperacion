output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.app.latest_version
}

output "instance_ids" {
  description = "IDs of instances launched by the ASG"
  value       = data.aws_instances.asg_instances.ids
}

output "public_ips" {
  description = "Public IP addresses of instances"
  value       = data.aws_instances.asg_instances.public_ips
}
