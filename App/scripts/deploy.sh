#!/bin/bash
# Deployment Script for Todo App to AWS EC2
# Usage: ./deploy.sh <ec2-ip> <key-file>

set -e

# ==================== Configuration ====================
EC2_IP=${1:-"your-ec2-ip"}
KEY_FILE=${2:-"~/.ssh/your-key.pem"}
EC2_USER="ec2-user"
APP_DIR="/var/www/todo-app"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ==================== Functions ====================
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ==================== Validation ====================
if [ "$EC2_IP" == "your-ec2-ip" ]; then
    log_error "Please provide EC2 IP address"
    echo "Usage: $0 <ec2-ip> <key-file>"
    exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
    log_error "Key file not found: $KEY_FILE"
    exit 1
fi

log_info "Starting deployment to EC2: $EC2_IP"

# ==================== Create Archive ====================
log_info "Creating application archive..."
cd "$LOCAL_DIR"

tar -czf /tmp/todo-app.tar.gz \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='.env' \
    --exclude='*.log' \
    --exclude='scripts' \
    server.js \
    package.json \
    config/ \
    views/ \
    public/ \
    .env.example

log_info "Archive created: /tmp/todo-app.tar.gz"

# ==================== Upload to EC2 ====================
log_info "Uploading application to EC2..."
scp -i "$KEY_FILE" /tmp/todo-app.tar.gz ${EC2_USER}@${EC2_IP}:/tmp/

# ==================== Deploy on EC2 ====================
log_info "Deploying application on EC2..."
ssh -i "$KEY_FILE" ${EC2_USER}@${EC2_IP} << 'ENDSSH'
    set -e
    
    echo "Creating application directory..."
    sudo mkdir -p /var/www/todo-app
    sudo chown -R ec2-user:ec2-user /var/www/todo-app
    
    echo "Extracting application..."
    cd /var/www/todo-app
    tar -xzf /tmp/todo-app.tar.gz
    
    echo "Setting up environment..."
    if [ ! -f .env ]; then
        cp .env.example .env
        echo "⚠️  Please update .env file with your database credentials"
    fi
    
    echo "Installing Node.js if not present..."
    if ! command -v node &> /dev/null; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    fi
    
    echo "Installing dependencies..."
    npm install --production
    
    echo "Installing PM2 if not present..."
    if ! command -v pm2 &> /dev/null; then
        sudo npm install -g pm2
    fi
    
    echo "Allowing Node to bind to port 80..."
    sudo setcap 'cap_net_bind_service=+ep' $(which node)
    
    echo "Stopping existing application..."
    pm2 delete todo-app 2>/dev/null || true
    
    echo "Starting application..."
    pm2 start server.js --name todo-app --time
    
    echo "Configuring PM2 startup..."
    pm2 startup systemd -u ec2-user --hp /home/ec2-user
    pm2 save
    
    echo "Application deployed successfully!"
    pm2 status
    
    echo ""
    echo "=========================================="
    echo "Deployment Complete!"
    echo "=========================================="
    echo "Next steps:"
    echo "1. Update .env file with RDS credentials:"
    echo "   ssh -i your-key.pem ec2-user@${EC2_IP}"
    echo "   nano /var/www/todo-app/.env"
    echo ""
    echo "2. Restart the application:"
    echo "   pm2 restart todo-app"
    echo ""
    echo "3. Check logs:"
    echo "   pm2 logs todo-app"
    echo "=========================================="
ENDSSH

# ==================== Cleanup ====================
log_info "Cleaning up..."
rm -f /tmp/todo-app.tar.gz

# ==================== Test Deployment ====================
log_info "Testing deployment..."
sleep 5

if ssh -i "$KEY_FILE" ${EC2_USER}@${EC2_IP} "curl -f http://localhost/api/health" > /dev/null 2>&1; then
    log_info "✅ Health check passed"
else
    log_warn "⚠️  Health check failed - app may need configuration"
fi

echo ""
log_info "=========================================="
log_info "Deployment completed successfully!"
log_info "=========================================="
log_info "Application URL: http://${EC2_IP}"
log_info "Health Check: http://${EC2_IP}/api/health"
log_info ""
log_info "SSH to server: ssh -i ${KEY_FILE} ${EC2_USER}@${EC2_IP}"
log_info "View logs: ssh -i ${KEY_FILE} ${EC2_USER}@${EC2_IP} 'pm2 logs todo-app'"
log_info "=========================================="
