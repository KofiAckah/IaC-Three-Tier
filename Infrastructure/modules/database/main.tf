# ### Module 5: RDS Database Layer
# Must include:
# - RDS instance
# - DB subnet group
# - DB security group reference

# Outputs:
# - RDS endpoint
# - Port

# Local variables for consistent tagging

# 1. DB Subnet Group
resource "aws_db_subnet_group" "main" {
  # Add prefix "db-" to ensure name starts with a letter
  name       = "db-${var.project_name}-${var.environment}-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
      Tier = "Database"
    }
  )
}

# 2. RDS MySQL Instance
resource "aws_db_instance" "main" {
  # Add prefix "db-" to ensure identifier starts with a letter
  identifier = "db-${var.project_name}-${var.environment}-mysql"

  # Engine Configuration
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = var.db_storage_type
  storage_encrypted = var.db_storage_encrypted

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false

  # Backup Configuration
  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window

  # High Availability
  multi_az = var.db_multi_az

  # Snapshot Configuration
  skip_final_snapshot = var.db_skip_final_snapshot
  # Add "db-" prefix to final snapshot identifier
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : "db-${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Monitoring
  enabled_cloudwatch_logs_exports = var.db_enabled_cloudwatch_logs_exports

  # Other Settings
  auto_minor_version_upgrade = true
  deletion_protection        = var.db_deletion_protection

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-mysql"
      Tier = "Database"
    }
  )
}
