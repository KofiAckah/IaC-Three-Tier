# AWS Provider Configuration Variables
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-central-1"
}

# Project Tagging Variables
variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "iac-3tier"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "joel-livingstone-kofi-ackah"
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ==================== ALB Variables ====================

variable "target_port" {
  description = "Port on which targets receive traffic from ALB"
  type        = number
  default     = 80
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "enable_stickiness" {
  description = "Enable session stickiness on ALB"
  type        = bool
  default     = false
}

# ==================== Health Check Variables ====================

variable "health_check_path" {
  description = "Path for ALB health check endpoint (Todo App: /api/health)"
  type        = string
  default     = "/api/health"
}

variable "health_check_interval" {
  description = "Interval between health checks in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health check in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks required"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks required"
  type        = number
  default     = 2
}

# ==================== Compute/ASG Variables ====================

variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
  default     = ""
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 4
}

variable "health_check_type" {
  description = "Type of health check for ASG (EC2 or ELB)"
  type        = string
  default     = "ELB"
}

variable "health_check_grace_period" {
  description = "Time in seconds after instance launch before health checks start"
  type        = number
  default     = 300
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "volume_size" {
  description = "Size of EBS volume in GB"
  type        = number
  default     = 20
}

variable "volume_type" {
  description = "Type of EBS volume (gp2, gp3, io1, etc.)"
  type        = string
  default     = "gp3"
}