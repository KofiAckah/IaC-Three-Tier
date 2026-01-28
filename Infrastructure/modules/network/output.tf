# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

# Private App Subnet Outputs
output "private_app_subnet_ids" {
  description = "List of private application subnet IDs"
  value       = aws_subnet.private_app[*].id
}

# Private DB Subnet Outputs
output "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  value       = aws_subnet.private_db[*].id
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_app_route_table_id" {
  description = "IDs of the private app route tables"
  value       = aws_route_table.private_app[*].id
}

output "private_db_route_table_id" {
  description = "ID of the private DB route table"
  value       = aws_route_table.private_db.id
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.nat[*].id
}

output "nat_gateway_ips" {
  description = "Elastic IPs of the NAT Gateways"
  value       = aws_eip.nat_eip[*].public_ip
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}