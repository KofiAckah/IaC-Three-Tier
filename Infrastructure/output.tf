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
  description = "ID of the NAT Gateway"
  value       = module.network.nat_gateway_id
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
