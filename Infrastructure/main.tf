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
