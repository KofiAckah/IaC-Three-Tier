#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "===== Starting Application Deployment ====="
echo "Timestamp: $(date)"

# Update system packages
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Wait for Docker to be ready
until docker info > /dev/null 2>&1; do
  echo "Waiting for Docker to be ready..."
  sleep 2
done

# Pull the application image from Docker Hub
echo "Pulling application image from Docker Hub..."
docker pull livingstoneackah/todo-app:latest

# Run the application container
echo "Starting application container..."
docker run -d \
  --name todo-app \
  --restart always \
  -p 80:3000 \
  -e DB_TYPE=mysql \
  -e DB_HOST=${db_endpoint} \
  -e DB_PORT=3306 \
  -e DB_NAME=${db_name} \
  -e DB_USER=${db_username} \
  -e DB_PASSWORD=${db_password} \
  -e PORT=3000 \
  -e NODE_ENV=production \
  livingstoneackah/todo-app:latest

# Wait for application to start
echo "Waiting for application to start..."
sleep 30

# Test the application
echo "Testing application..."
curl -f http://localhost/api/health || curl -f http://localhost/ || echo "Application starting..."

echo "===== Deployment Complete ====="
echo "Application is running on port 80 (mapped from container port 3000)"
echo "Docker status:"
docker ps