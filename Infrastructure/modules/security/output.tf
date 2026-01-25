# Security Group Outputs
output "web_sg_id" {
  description = "ID of the Web/ALB security group"
  value       = aws_security_group.web_sg.id
}

output "app_sg_id" {
  description = "ID of the Application security group"
  value       = aws_security_group.app_sg.id
}

output "db_sg_id" {
  description = "ID of the Database security group"
  value       = aws_security_group.db_sg.id
}

# Additional useful outputs
output "web_sg_name" {
  description = "Name of the Web security group"
  value       = aws_security_group.web_sg.name
}

output "app_sg_name" {
  description = "Name of the App security group"
  value       = aws_security_group.app_sg.name
}

output "db_sg_name" {
  description = "Name of the DB security group"
  value       = aws_security_group.db_sg.name
}