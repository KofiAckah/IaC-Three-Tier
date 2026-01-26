# ==================== ALB Outputs ====================

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.app_alb.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.app_alb.zone_id
}

# ==================== Target Group Outputs ====================

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_tg.arn
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.app_tg.id
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.app_tg.name
}

# ==================== Listener Outputs ====================

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "http_listener_id" {
  description = "ID of the HTTP listener"
  value       = aws_lb_listener.http.id
}

# ==================== Useful Information ====================

output "alb_url" {
  description = "URL to access the application via ALB"
  value       = "http://${aws_lb.app_alb.dns_name}"
}

output "health_check_path" {
  description = "Health check path configured for target group"
  value       = var.health_check_path
}