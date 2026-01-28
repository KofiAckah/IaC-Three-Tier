# ### Module 2: Security
# Must include:
# - 3 Security Groups (Web, App, and DB)
# - Ingress Rules for Allowed Traffic Per Tier

# Outputs:
# - Security Group IDs

# 1. Web Security Group (For ALB)
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-web-sg"
      Tier = "Web"
    }
  )
}

# Web - Allow HTTP from Internet
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "HTTP from Internet"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-web-http-rule"
    }
  )
}

# Web - Allow HTTPS from Internet
resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "HTTPS from Internet"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-web-https-rule"
    }
  )
}

# Web - Allow ICMP from Internet
resource "aws_vpc_security_group_ingress_rule" "web_icmp" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
  description       = "ICMP from Internet"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-web-icmp-rule"
    }
  )
}

# Web - Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-web-egress-rule"
    }
  )
}

# 2. App Security Group (For EC2/ASG)
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for Application servers (EC2/ASG)"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-app-sg"
      Tier = "Application"
    }
  )
}

# App - Allow HTTP from Web SG (ALB)
resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.web_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
  description                  = "HTTP from ALB"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-app-http-rule"
    }
  )
}

#  App - Allow HTTPS from Web SG (ALB)
resource "aws_vpc_security_group_ingress_rule" "app_https" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.web_sg.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
  description                  = "HTTPS from ALB"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-app-https-rule"
    }
  )
}

# App - Allow SSH from VPC
resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "SSH from VPC"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-app-ssh-rule"
    }
  )
}

# App - Allow ICMP from Web SG
resource "aws_vpc_security_group_ingress_rule" "app_icmp_web" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.web_sg.id
  from_port                    = -1
  ip_protocol                  = "icmp"
  to_port                      = -1
  description                  = "ICMP from Web tier"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-app-icmp-web-rule"
    }
  )
}

# App - Allow ICMP from VPC
resource "aws_vpc_security_group_ingress_rule" "app_icmp_vpc" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
  description       = "ICMP from VPC"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-app-icmp-vpc-rule"
    }
  )
}

# App - Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-app-egress-rule"
    }
  )
}

# 3. DB Security Group (For RDS)
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-db-sg"
      Tier = "Database"
    }
  )
}

# DB - Allow MySQL from App SG
resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
  description                  = "MySQL from App tier"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-db-mysql-rule"
    }
  )
}

# DB - Allow PostgreSQL from App SG
resource "aws_vpc_security_group_ingress_rule" "db_postgresql" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  description                  = "PostgreSQL from App tier"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-db-postgresql-rule"
    }
  )
}

# DB - Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-db-egress-rule"
    }
  )
}