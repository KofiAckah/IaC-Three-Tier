# ==================== Application Load Balancer Module ====================
# This module creates:
# - Application Load Balancer (ALB)
# - HTTP Listener (Port 80)
# - Target Group for EC2 instances
# - Health checks configured for Todo App

# ==================== Application Load Balancer ====================
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg_id]
  subnets           = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

# ==================== Target Group ====================
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Health check configuration for Todo App
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path  # /api/health for Todo App
    protocol            = "HTTP"
    matcher             = "200"  # Success status code
  }

  # Deregistration delay
  deregistration_delay = var.deregistration_delay

  # Stickiness (optional)
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # 1 day
    enabled         = var.enable_stickiness
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-target-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ==================== HTTP Listener ====================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-http-listener"
    }
  )
}

# ==================== HTTPS Listener (Optional - for future SSL) ====================
# Uncomment when you have an SSL certificate
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = var.certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }

# ==================== HTTP to HTTPS Redirect (Optional) ====================
# Uncomment when you enable HTTPS
# resource "aws_lb_listener" "redirect_http_to_https" {
#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = "80"
#   protocol          = "HTTP"
#
#   default_action {
#     type = "redirect"
#
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }