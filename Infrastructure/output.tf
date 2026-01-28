# Root Level Outputs
# These outputs expose important information from all modules

# ============================================
# Network Module Outputs
# ============================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of private application subnet IDs"
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  value       = module.network.private_db_subnet_ids
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.network.public_route_table_id
}

output "private_app_route_table_id" {
  description = "ID of the private app route table"
  value       = module.network.private_app_route_table_id
}

output "private_db_route_table_id" {
  description = "ID of the private DB route table"
  value       = module.network.private_db_route_table_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "IDs of the NAT Gateways"
  value       = module.network.nat_gateway_id
}

output "nat_gateway_ips" {
  description = "Elastic IPs of the NAT Gateways"
  value       = module.network.nat_gateway_ips
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.network.availability_zones
}

# ============================================
# Security Module Outputs
# ============================================

output "web_security_group_id" {
  description = "ID of the Web/ALB security group"
  value       = module.security.web_sg_id
}

output "app_security_group_id" {
  description = "ID of the Application security group"
  value       = module.security.app_sg_id
}

output "db_security_group_id" {
  description = "ID of the Database security group"
  value       = module.security.db_sg_id
}

output "web_security_group_name" {
  description = "Name of the Web security group"
  value       = module.security.web_sg_name
}

output "app_security_group_name" {
  description = "Name of the App security group"
  value       = module.security.app_sg_name
}

output "db_security_group_name" {
  description = "Name of the DB security group"
  value       = module.security.db_sg_name
}

# ============================================
# ALB Module Outputs
# ============================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL to access the application via ALB"
  value       = module.alb.alb_url
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_group_arn
}

output "target_group_name" {
  description = "Name of the ALB target group"
  value       = module.alb.target_group_name
}

output "health_check_path" {
  description = "Health check path configured for ALB target group"
  value       = module.alb.health_check_path
}

# ============================================
# Database Module Outputs
# ============================================

output "rds_endpoint" {
  description = "RDS instance endpoint (includes port)"
  value       = module.database.rds_endpoint
}

output "rds_address" {
  description = "RDS instance address (hostname without port)"
  value       = module.database.rds_address
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.database.rds_port
}

output "db_name" {
  description = "Database name"
  value       = module.database.db_name
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = module.database.db_subnet_group_name
}

output "db_info" {
  description = "Complete database information"
  value       = module.database.db_info
}

# ============================================
# Compute Module Outputs (Auto Scaling Group)
# ============================================

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.asg_arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = module.compute.launch_template_id
}

output "asg_desired_capacity" {
  description = "Desired capacity of the ASG"
  value       = module.compute.asg_desired_capacity
}

output "asg_min_size" {
  description = "Minimum size of the ASG"
  value       = module.compute.asg_min_size
}

output "asg_max_size" {
  description = "Maximum size of the ASG"
  value       = module.compute.asg_max_size
}

output "asg_info" {
  description = "Complete Auto Scaling Group information"
  value       = module.compute.asg_info
}

# ============================================
# Deployment Summary
# ============================================

output "deployment_summary" {
  description = "Complete deployment summary with all key information"
  value = {
    # Network
    vpc_id             = module.network.vpc_id
    availability_zones = module.network.availability_zones
    nat_gateway_id     = module.network.nat_gateway_id

    # Security
    web_sg_id = module.security.web_sg_id
    app_sg_id = module.security.app_sg_id
    db_sg_id  = module.security.db_sg_id

    # Application Load Balancer
    alb_dns_name     = module.alb.alb_dns_name
    alb_url          = module.alb.alb_url
    target_group_arn = module.alb.target_group_arn

    # Compute
    asg_name     = module.compute.asg_name
    asg_capacity = module.compute.asg_desired_capacity

    # Database
    rds_endpoint = module.database.rds_endpoint
    db_name      = module.database.db_name
  }
}
