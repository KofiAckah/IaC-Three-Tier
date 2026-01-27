# Terraform Integration Guide

## Integrating Todo App with Your 3-Tier Infrastructure

This guide explains how to integrate the Todo App with your existing Terraform infrastructure.

---

## 📋 Overview

The Todo App will be deployed to your EC2 instances in the **Application Layer (Tier 2)** and connected to your **RDS database (Tier 3)** through your **ALB (Tier 1)**.

---

## 🔧 Step 1: Update Compute Module

### Update `Infrastructure/modules/compute/main.tf`

Add the user data script to your Launch Template or EC2 instances:

```hcl
# In your aws_launch_template or aws_instance resource

data "template_file" "user_data" {
  template = file("${path.root}/../App/scripts/user-data.sh")
  
  vars = {
    db_type     = "mysql"  # or "postgresql"
    db_host     = var.rds_endpoint
    db_port     = "3306"   # or "5432" for PostgreSQL
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  
  user_data = base64encode(data.template_file.user_data.rendered)
  
  # ... rest of your configuration
}
```

### Update `Infrastructure/modules/compute/variables.tf`

Add these variables:

```hcl
variable "rds_endpoint" {
  description = "RDS database endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "tododb"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

---

## 🔧 Step 2: Update ALB Module

### Update `Infrastructure/modules/alb/main.tf`

Configure health check for the Todo App:

```hcl
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/health"  # Todo App health endpoint
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-target-group"
    }
  )
}
```

---

## 🔧 Step 3: Update Root Main Configuration

### Update `Infrastructure/main.tf`

Pass the RDS endpoint to the compute module:

```hcl
module "compute" {
  source = "./modules/compute"

  # ... existing variables

  # Add these for Todo App
  rds_endpoint = module.database.rds_endpoint
  db_name      = var.db_name
  db_user      = var.db_user
  db_password  = var.db_password

  depends_on = [module.network, module.security, module.database]
}
```

### Update `Infrastructure/variables.tf`

Add database credentials:

```hcl
variable "db_name" {
  description = "Database name for Todo App"
  type        = string
  default     = "tododb"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### Update Environment Files

Update `Infrastructure/dev.tfvars`:

```hcl
# Existing variables...

# Database Configuration
db_name     = "tododb"
db_user     = "admin"
db_password = "YourSecureDevPassword123!"  # Change in production!
```

---

## 🔧 Step 4: Deploy Application Code to EC2

### Option A: Using S3 (Recommended for Production)

1. **Create S3 bucket for deployment artifacts:**

```bash
aws s3 mb s3://your-app-deployment-bucket
```

2. **Package and upload Todo App:**

```bash
cd App
tar -czf ../todo-app.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  server.js package.json config/ views/ public/

aws s3 cp ../todo-app.tar.gz s3://your-app-deployment-bucket/
```

3. **Update user-data.sh to download from S3:**

```bash
# In user-data.sh, add:
aws s3 cp s3://your-app-deployment-bucket/todo-app.tar.gz /tmp/
tar -xzf /tmp/todo-app.tar.gz -C /var/www/todo-app
```

### Option B: Using Terraform File Provisioner

Add to your EC2/Launch Template:

```hcl
resource "null_resource" "deploy_app" {
  triggers = {
    instance_id = aws_instance.app.id
  }

  provisioner "file" {
    source      = "${path.root}/../App"
    destination = "/tmp/todo-app"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.app.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/www/todo-app",
      "sudo cp -r /tmp/todo-app/* /var/www/todo-app/",
      "sudo chown -R ec2-user:ec2-user /var/www/todo-app"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.app.public_ip
    }
  }
}
```

---

## 🔧 Step 5: Update Security Groups

Ensure your security groups allow proper traffic:

### Web Security Group (ALB)
- Inbound: HTTP (80) from 0.0.0.0/0
- Inbound: HTTPS (443) from 0.0.0.0/0
- Outbound: All traffic to App SG

### App Security Group (EC2)
- Inbound: HTTP (80) from Web SG
- Inbound: SSH (22) from Bastion SG (for deployment)
- Outbound: MySQL (3306) or PostgreSQL (5432) to DB SG
- Outbound: HTTP/HTTPS for package downloads

### DB Security Group (RDS)
- Inbound: MySQL (3306) or PostgreSQL (5432) from App SG

---

## 🚀 Deployment Steps

### 1. Initialize Terraform

```bash
cd Infrastructure
terraform init
```

### 2. Plan Deployment

```bash
terraform plan -var-file="dev.tfvars"
```

### 3. Apply Configuration

```bash
terraform apply -var-file="dev.tfvars"
```

### 4. Get Outputs

```bash
terraform output
```

You should see:
- ALB DNS name
- RDS endpoint
- EC2 instance IDs

### 5. Test Deployment

```bash
# Wait a few minutes for user-data to complete

# Test health check
curl http://your-alb-dns-name/api/health

# Access web UI
open http://your-alb-dns-name
```

---

## 🔍 Verification Steps

### 1. Check EC2 Instances

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@your-ec2-ip

# Check if app is running
pm2 status

# View logs
pm2 logs todo-app

# Check health locally
curl http://localhost/api/health
```

### 2. Check ALB Target Health

In AWS Console:
1. Navigate to EC2 > Target Groups
2. Select your target group
3. Check "Targets" tab - should show "healthy"

### 3. Test Database Connection

```bash
# From EC2 instance
mysql -h your-rds-endpoint -u admin -p

# Or test through app
curl http://localhost/api/todos
```

---

## 📊 Monitoring

### CloudWatch Logs

Add to user-data.sh:

```bash
# Install CloudWatch agent
sudo yum install -y amazon-cloudwatch-agent

# Configure logs
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/config.json << 'EOF'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/aws/ec2/todo-app",
            "log_stream_name": "{instance_id}/user-data"
          }
        ]
      }
    }
  }
}
EOF

# Start agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json \
  -s
```

---

## 🔒 Security Best Practices

### 1. Use AWS Secrets Manager

```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-${var.environment}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# In user-data, retrieve secret:
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id ${var.project_name}-${var.environment}-db-password \
  --query SecretString \
  --output text)
```

### 2. Enable RDS Encryption

```hcl
resource "aws_db_instance" "main" {
  # ...
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
}
```

### 3. Use IAM Roles

```hcl
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
```

---

## 🔄 CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Todo App

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Package application
        run: |
          cd App
          tar -czf todo-app.tar.gz \
            --exclude='node_modules' \
            server.js package.json config/ views/ public/
      
      - name: Upload to S3
        run: |
          aws s3 cp App/todo-app.tar.gz s3://your-deployment-bucket/
      
      - name: Deploy to EC2
        run: |
          # Trigger deployment script or use AWS Systems Manager
          aws ssm send-command \
            --targets "Key=tag:Environment,Values=production" \
            --document-name "AWS-RunShellScript" \
            --parameters 'commands=["cd /var/www/todo-app && pm2 restart todo-app"]'
```

---

## 📞 Support

For issues:
- Infrastructure: Check Terraform logs
- Application: Check PM2 logs (`pm2 logs todo-app`)
- Database: Check RDS CloudWatch metrics

---

**Happy Deploying! 🚀**
