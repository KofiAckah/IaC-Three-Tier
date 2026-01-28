# Root Main Terraform Configuration
# This file orchestrates all modules for the 3-Tier Architecture

# Network Module
module "network" {
  source = "./modules/network"

  # Pass variables to network module
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment

  # Merge common tags with module-specific tags
  tags = merge(
    var.common_tags,
    {
      Module      = "Network"
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
    }
  )
}

# Security Module
module "security" {
  source = "./modules/security"

  # Pass required variables
  vpc_id       = module.network.vpc_id
  vpc_cidr     = module.network.vpc_cidr
  project_name = var.project_name
  environment  = var.environment

  # Merge common tags
  tags = merge(
    var.common_tags,
    {
      Module      = "Security"
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
    }
  )

  # Ensure network is created first
  depends_on = [module.network]
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  # Pass required variables
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  web_sg_id         = module.security.web_sg_id
  project_name      = var.project_name
  environment       = var.environment

  # Health check configuration for Todo App
  health_check_path                = var.health_check_path
  health_check_interval            = var.health_check_interval
  health_check_timeout             = var.health_check_timeout
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold

  # ALB configuration
  target_port                = var.target_port
  enable_deletion_protection = var.enable_deletion_protection
  enable_stickiness          = var.enable_stickiness

  # Merge common tags
  tags = merge(
    var.common_tags,
    {
      Module      = "ALB"
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
    }
  )

  # Ensure network and security are created first
  depends_on = [module.network, module.security]
}

# Database Module
module "database" {
  source = "./modules/database"

  # Network Configuration
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_sg_id              = module.security.db_sg_id

  # Project Configuration
  project_name = var.project_name
  environment  = var.environment

  # Database Configuration
  db_engine            = "mysql"
  db_engine_version    = "8.0"
  db_instance_class    = "db.t3.micro"
  db_allocated_storage = 20
  db_storage_type      = "gp3"
  db_storage_encrypted = true

  # Database Credentials
  db_name     = "tododb"
  db_username = "admin"
  db_password = "SecurePassword123!" # CHANGE THIS IN PRODUCTION!

  # Backup Configuration
  db_backup_retention_period = 7
  db_backup_window           = "03:00-04:00"
  db_maintenance_window      = "mon:04:00-mon:05:00"

  # High Availability
  db_multi_az = false

  # Snapshot Configuration
  db_skip_final_snapshot = true

  # Deletion Protection
  db_deletion_protection = false

  # Tags
  tags = merge(
    var.common_tags,
    {
      Module      = "Database"
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
    }
  )

  depends_on = [module.network, module.security]
}

# Compute Module (Auto Scaling Group - Option A)
module "compute" {
  source = "./modules/compute"

  # Network Configuration
  private_app_subnet_ids = module.network.private_app_subnet_ids

  # Security Group
  app_sg_id = module.security.app_sg_id

  # ALB Target Group
  target_group_arn = module.alb.target_group_arn

  # Project Configuration
  project_name = var.project_name
  environment  = var.environment

  # EC2 Configuration
  instance_type     = var.instance_type
  key_name          = var.key_name
  volume_size       = var.volume_size
  volume_type       = var.volume_type
  enable_monitoring = var.enable_monitoring

  # Auto Scaling Configuration
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  # Database Configuration (for user data script)
  db_endpoint = module.database.rds_address
  db_name     = "tododb"
  db_username = "admin"
  db_password = "SecurePassword123!" # MUST match database module password

  # Tags
  tags = merge(
    var.common_tags,
    {
      Module      = "Compute"
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
    }
  )

  depends_on = [module.network, module.security, module.alb, module.database]
}
