# ==================== Required Variables ====================

variable "vpc_id" {
  description = "ID of the VPC where ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB placement"
  type        = list(string)
}

variable "web_sg_id" {
  description = "ID of the Web/ALB security group"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# ==================== Optional Variables ====================

variable "tags" {
  description = "Tags to apply to ALB resources"
  type        = map(string)
  default     = {}
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "enable_stickiness" {
  description = "Enable session stickiness"
  type        = bool
  default     = false
}

variable "deregistration_delay" {
  description = "Time in seconds before deregistering a target"
  type        = number
  default     = 300
}

# ==================== Health Check Variables ====================

variable "health_check_path" {
  description = "Path for health check endpoint"
  type        = string
  default     = "/api/health"
}

variable "health_check_interval" {
  description = "Interval between health checks (seconds)"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health check (seconds)"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 2
}

# ==================== Optional SSL Variables ====================
# Uncomment when you want to enable HTTPS

# variable "certificate_arn" {
#   description = "ARN of the SSL certificate for HTTPS listener"
#   type        = string
#   default     = ""
# }