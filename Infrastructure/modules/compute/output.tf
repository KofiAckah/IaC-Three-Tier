# Compute Module Outputs

# Launch Template Outputs
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.app.latest_version
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.app.arn
}

# Auto Scaling Group Outputs
output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}

output "asg_availability_zones" {
  description = "Availability zones used by the ASG"
  value       = aws_autoscaling_group.app.availability_zones
}

output "asg_desired_capacity" {
  description = "Desired capacity of the ASG"
  value       = aws_autoscaling_group.app.desired_capacity
}

output "asg_min_size" {
  description = "Minimum size of the ASG"
  value       = aws_autoscaling_group.app.min_size
}

output "asg_max_size" {
  description = "Maximum size of the ASG"
  value       = aws_autoscaling_group.app.max_size
}

# Complete ASG Information
output "asg_info" {
  description = "Complete Auto Scaling Group information"
  value = {
    asg_name           = aws_autoscaling_group.app.name
    asg_arn            = aws_autoscaling_group.app.arn
    desired_capacity   = aws_autoscaling_group.app.desired_capacity
    min_size           = aws_autoscaling_group.app.min_size
    max_size           = aws_autoscaling_group.app.max_size
    launch_template    = aws_launch_template.app.id
    availability_zones = aws_autoscaling_group.app.availability_zones
  }
}
