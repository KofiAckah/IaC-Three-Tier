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
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  web_sg_id          = module.security.web_sg_id
  project_name       = var.project_name
  environment        = var.environment

  # Health check configuration for Todo App
  health_check_path              = var.health_check_path
  health_check_interval          = var.health_check_interval
  health_check_timeout           = var.health_check_timeout
  health_check_healthy_threshold = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold

  # ALB configuration
  target_port                = var.target_port
  enable_deletion_protection = var.enable_deletion_protection
  enable_stickiness         = var.enable_stickiness

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
