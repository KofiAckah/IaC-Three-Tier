#!/bin/bash
# EC2 User Data Script for Todo App Deployment
# This script runs when EC2 instance launches

set -e

# ==================== Variables ====================
APP_DIR="/var/www/todo-app"
APP_USER="ec2-user"
LOG_FILE="/var/log/user-data.log"

# Redirect output to log file
exec > >(tee -a ${LOG_FILE})
exec 2>&1

echo "=========================================="
echo "Todo App Deployment Started"
echo "Time: $(date)"
echo "=========================================="

# ==================== System Updates ====================
echo "[1/8] Updating system packages..."
sudo yum update -y

# ==================== Install Node.js ====================
echo "[2/8] Installing Node.js 18.x..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version
npm --version

# ==================== Install PM2 ====================
echo "[3/8] Installing PM2 process manager..."
sudo npm install -g pm2

# ==================== Install Docker (Optional) ====================
echo "[4/8] Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# ==================== Create Application Directory ====================
echo "[5/8] Creating application directory..."
sudo mkdir -p ${APP_DIR}
sudo chown -R ${APP_USER}:${APP_USER} ${APP_DIR}

# ==================== Download Application Code ====================
echo "[6/8] Downloading application code..."
cd ${APP_DIR}

# Option 1: From S3 (if you upload the app to S3)
# aws s3 cp s3://your-bucket/todo-app.tar.gz /tmp/
# tar -xzf /tmp/todo-app.tar.gz -C ${APP_DIR}

# Option 2: From GitHub (recommended)
# sudo yum install -y git
# git clone https://github.com/KofiAckah/Todo-App-3Tier.git .

# For now, we'll assume files are copied via Terraform provisioner or S3
# Create a placeholder - in real deployment, use one of the above methods

# ==================== Configure Environment ====================
echo "[7/8] Configuring environment variables..."
cat > ${APP_DIR}/.env << EOF
NODE_ENV=production
PORT=80

# Database Configuration (from Terraform)
DB_TYPE=${db_type}
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF

# ==================== Install Dependencies & Start App ====================
echo "[8/8] Installing dependencies and starting application..."

# If using npm (files already present)
if [ -f "${APP_DIR}/package.json" ]; then
    cd ${APP_DIR}
    npm install --production
    
    # Allow Node to bind to port 80
    sudo setcap 'cap_net_bind_service=+ep' $(which node)
    
    # Start with PM2
    pm2 delete todo-app 2>/dev/null || true
    pm2 start server.js --name todo-app --time
    
    # Configure PM2 to start on boot
    pm2 startup systemd -u ${APP_USER} --hp /home/${APP_USER}
    pm2 save
    
    # Enable PM2 startup
    sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ${APP_USER} --hp /home/${APP_USER}
fi

# ==================== Configure Firewall ====================
echo "Configuring firewall..."
# Allow HTTP traffic
sudo firewall-cmd --permanent --add-service=http 2>/dev/null || true
sudo firewall-cmd --reload 2>/dev/null || true

# ==================== Health Check ====================
echo "Waiting for application to start..."
sleep 10

# Check if app is running
if pm2 list | grep -q "todo-app"; then
    echo "✅ Application started successfully"
    pm2 status
else
    echo "❌ Application failed to start"
    exit 1
fi

# Test health endpoint
echo "Testing health endpoint..."
if curl -f http://localhost:80/api/health; then
    echo "✅ Health check passed"
else
    echo "⚠️  Health check failed (app may still be starting)"
fi

# ==================== Logging Setup ====================
echo "Setting up log rotation..."
sudo tee /etc/logrotate.d/todo-app > /dev/null << EOF
${LOG_FILE} {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF

echo "=========================================="
echo "Todo App Deployment Completed"
echo "Time: $(date)"
echo "=========================================="
echo "Application URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "Health Check: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/api/health"
echo "=========================================="

# Send completion signal to CloudWatch (optional)
# aws cloudwatch put-metric-data --metric-name DeploymentSuccess --namespace TodoApp --value 1
