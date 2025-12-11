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

# Note: Instance IDs and public IPs are created dynamically by ASG.
# To retrieve them, use:
# aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names hola-asg --query 'AutoScalingGroups[0].Instances[*].[InstanceId]'
# aws ec2 describe-instances --instance-ids <instance-id> --query 'Reservations[0].Instances[*].[InstanceId,PublicIpAddress]'
