# ### Module 4: Compute Layer (Auto Scaling Group - Option A)
# Required inputs from root module

# Network Configuration
variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs for ASG"
  type        = list(string)
}

# Security Group
variable "app_sg_id" {
  description = "Application security group ID"
  type        = string
}

# Target Group
variable "target_group_arn" {
  description = "ALB target group ARN for ASG attachment"
  type        = string
}

# Project Configuration
variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name for EC2 instances (optional)"
  type        = string
  default     = ""
}

# EBS Volume Configuration
variable "volume_size" {
  description = "Size of EBS volume in GB"
  type        = number
  default     = 20
}

variable "volume_type" {
  description = "Type of EBS volume (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

# Auto Scaling Configuration
variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 4
}

variable "health_check_type" {
  description = "Type of health check (EC2 or ELB)"
  type        = string
  default     = "ELB"
}

variable "health_check_grace_period" {
  description = "Time in seconds after instance launch before health checks start"
  type        = number
  default     = 300
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

# Database Configuration (for user data script)
variable "db_endpoint" {
  description = "RDS database endpoint address"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "tododb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

# User Data Script (optional custom script)
variable "user_data_script" {
  description = "Custom user data script (leave empty to use default Todo App deployment)"
  type        = string
  default     = ""
}
