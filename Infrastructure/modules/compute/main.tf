# ### Module 4: Compute Layer - Auto Scaling Group (Option A - Preferred)
# This module creates:
# - Launch Template with Ubuntu AMI and user data
# - Auto Scaling Group attached to ALB target group
# - Automatic deployment of Todo App with database connection

# Local variables for user data
locals {
  # Use templatefile to load and render the user data script with variables
  user_data = var.user_data_script != "" ? var.user_data_script : templatefile("${path.module}/scripts/docker-user-data.sh", {
    db_endpoint  = var.db_endpoint
    db_name      = var.db_name
    db_username  = var.db_username
    db_password  = var.db_password
  })
}

# ==================== Launch Template ====================
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  # Network interfaces configuration
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
    delete_on_termination       = true
  }

  # EBS Volume configuration
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  # User data for application deployment
  user_data = base64encode(local.user_data)

  # Enable detailed monitoring if specified
  monitoring {
    enabled = var.enable_monitoring
  }

  # Instance metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Tag specifications
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-${var.environment}-app-instance"
        Tier = "Application"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-${var.environment}-app-volume"
        Tier = "Application"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ==================== Auto Scaling Group ====================
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.private_app_subnet_ids
  target_group_arns   = [var.target_group_arn]

  # Capacity settings
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  # Health check configuration
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  # Launch template configuration
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Instance refresh settings for zero-downtime updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = var.health_check_grace_period
    }
  }

  # Termination policies
  termination_policies = ["OldestInstance", "Default"]

  # Enable metrics collection
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  # Wait for ELB health checks before considering instance healthy
  wait_for_capacity_timeout = "10m"

  # Tags
  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "Application"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # Allow manual scaling
  }

  depends_on = [aws_launch_template.app]
}
