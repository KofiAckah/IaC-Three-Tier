# 📝 Todo App - Professional 3-Tier AWS Architecture

A production-ready, containerized Todo application built with Node.js/Express, designed to demonstrate modern DevOps practices and AWS 3-Tier Architecture deployment.

![Node.js](https://img.shields.io/badge/Node.js-18+-green)
![Express](https://img.shields.io/badge/Express-4.18-blue)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue)
![AWS](https://img.shields.io/badge/AWS-3--Tier-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📑 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Docker Containerization](#-docker-containerization-tutorial)
- [AWS Deployment](#-aws-deployment)
- [API Documentation](#-api-documentation)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

## 🏗️ Architecture Overview

This application is designed to work with a **3-Tier AWS Architecture**:

```
┌─────────────────────────────────────────────────────────┐
│              Tier 1: Presentation Layer                 │
│         (Application Load Balancer - Public)            │
└────────────────────┬────────────────────────────────────┘
                     │
      ┌──────────────┴──────────────┐
      │                             │
┌─────▼─────────┐           ┌───────▼──────┐
│  Public       │           │   Public     │
│  Subnet A     │           │   Subnet B   │
└─────┬─────────┘           └───────┬──────┘
      │                             │
      │   Tier 2: Application Layer │
      │   (EC2/ASG - Private)       │
      │                             │
┌─────▼─────────┐           ┌───────▼──────┐
│  Todo App     │           │   Todo App   │
│  Container    │           │   Container  │
└─────┬─────────┘           └───────┬──────┘
      │                             │
      └──────────────┬──────────────┘
                     │
            ┌────────▼─────────┐
            │  Tier 3: Data    │
            │  RDS MySQL/PG    │
            │  (Private)       │
            └──────────────────┘
```

### Components:
- **Tier 1 (Presentation)**: ALB for load balancing and SSL termination
- **Tier 2 (Application)**: Docker containers running Node.js app on EC2
- **Tier 3 (Data)**: RDS MySQL/PostgreSQL for persistent storage

---

## ✨ Features

### Application Features
- ✅ Create, read, update, delete (CRUD) todos
- ✅ Mark todos as complete/incomplete
- ✅ Beautiful responsive web UI
- ✅ RESTful API endpoints
- ✅ Real-time updates without page refresh
- ✅ Filter todos (All/Active/Completed)
- ✅ Bulk delete completed todos

### Technical Features
- 🐳 **Fully Dockerized** with multi-stage builds
- 🔄 **Health check endpoints** for ALB integration
- 📊 **Support for MySQL and PostgreSQL**
- 🚀 **Production-ready** with PM2 process manager
- 🔒 **Security best practices** (non-root user, secrets management)
- 📦 **Automated deployment** scripts
- 🔍 **Comprehensive logging** and monitoring
- 🎨 **Modern UI** with animations and responsive design

---

## 📂 Project Structure

```
App/
├── server.js                 # Main Express application
├── package.json              # Node.js dependencies
├── Dockerfile                # Multi-stage Docker build
├── docker-compose.yml        # Local development with Docker
├── .dockerignore             # Docker build exclusions
├── .env.example              # Environment template
├── .gitignore                # Git exclusions
├── nginx.conf                # Nginx reverse proxy config
│
├── config/
│   └── database.js           # Database connection handler
│
├── views/
│   └── index.ejs             # Main web interface
│
├── public/
│   ├── css/
│   │   └── style.css         # Application styles
│   └── js/
│       └── app.js            # Frontend JavaScript
│
└── scripts/
    ├── user-data.sh          # EC2 initialization script
    ├── deploy.sh             # Automated deployment
    ├── init-db.sh            # Database setup
    └── test-local.sh         # Local testing
```

---

## 📋 Prerequisites

### Local Development
- Node.js 14+ and npm
- Docker and Docker Compose (for containerization)
- MySQL or PostgreSQL (or use Docker Compose)

### AWS Deployment
- AWS Account with appropriate permissions
- Terraform (for infrastructure provisioning)
- EC2 key pair
- Basic understanding of AWS services (VPC, EC2, RDS, ALB)

---

## 🚀 Quick Start

### Option 1: Run Locally with Node.js

```bash
# 1. Navigate to the App directory
cd App

# 2. Install dependencies
npm install

# 3. Configure environment
cp .env.example .env
# Edit .env with your database credentials

# 4. Start the application
npm run dev          # Development mode (port 3000)
# OR
npm start            # Production mode

# 5. Access the app
# Open: http://localhost:3000
```

### Option 2: Run with Docker Compose (Recommended for Learning)

```bash
# 1. Navigate to the App directory
cd App

# 2. Start all services (app + MySQL)
docker-compose up -d

# 3. Check status
docker-compose ps

# 4. View logs
docker-compose logs -f app

# 5. Access the app
# Open: http://localhost:3000

# 6. Stop services
docker-compose down

# To use PostgreSQL instead:
docker-compose --profile postgres up -d
```

---

## 🐳 Docker Containerization Tutorial

### Understanding Docker for This App

Docker allows us to package our application with all its dependencies into a container that can run consistently anywhere.

### Step 1: Understanding the Dockerfile

Our `Dockerfile` uses a **multi-stage build** for efficiency:

```dockerfile
# Stage 1: Install dependencies
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Create production image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER nodejs  # Run as non-root for security
CMD ["node", "server.js"]
```

**Benefits:**
- Smaller image size (only production dependencies)
- Better security (non-root user)
- Faster builds with layer caching

### Step 2: Building the Docker Image

```bash
# Build the image
docker build -t todo-app:latest .

# Check the image
docker images | grep todo-app

# The image should be ~150MB (Alpine Linux is lightweight)
```

### Step 3: Running the Container

```bash
# Run with environment variables
docker run -d \
  --name todo-app \
  -p 3000:3000 \
  -e DB_TYPE=mysql \
  -e DB_HOST=your-rds-endpoint \
  -e DB_NAME=tododb \
  -e DB_USER=admin \
  -e DB_PASSWORD=yourpassword \
  todo-app:latest

# Check if running
docker ps

# View logs
docker logs -f todo-app

# Execute commands inside container
docker exec -it todo-app sh

# Stop and remove
docker stop todo-app
docker rm todo-app
```

### Step 4: Using Docker Compose for Multi-Container Setup

Docker Compose manages multiple containers (app + database):

```bash
# Start everything
docker-compose up -d

# This starts:
# - MySQL database (port 3306)
# - Todo app (port 3000)
# - Automatic networking between containers

# Scale the app (for load balancing practice)
docker-compose up -d --scale app=3

# View all containers
docker-compose ps

# Stop everything
docker-compose down

# Remove volumes too (clean database)
docker-compose down -v
```

### Step 5: Deploying Container to AWS ECS (Optional Advanced)

```bash
# 1. Build for AWS region
docker build --platform linux/amd64 -t todo-app:latest .

# 2. Tag for ECR
docker tag todo-app:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/todo-app:latest

# 3. Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com

# 4. Push image
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/todo-app:latest

# Then deploy using ECS/Fargate or EC2 with Docker
```

---

## ☁️ AWS Deployment

### Method 1: Terraform-Automated Deployment

Your Terraform infrastructure will automatically deploy this app. See [TERRAFORM-INTEGRATION.md](TERRAFORM-INTEGRATION.md) for details.

### Method 2: Manual Deployment to EC2

```bash
# 1. Make deployment script executable
chmod +x scripts/deploy.sh

# 2. Run deployment
./scripts/deploy.sh <ec2-ip> <path-to-key.pem>

# Example:
./scripts/deploy.sh 3.15.123.45 ~/.ssh/my-key.pem
```

The script will:
1. Package your application
2. Upload to EC2
3. Install Node.js and dependencies
4. Configure PM2 process manager
5. Start the application

### Method 3: Docker on EC2

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@your-ec2-ip

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Pull and run your image
docker run -d \
  --name todo-app \
  --restart unless-stopped \
  -p 80:3000 \
  -e DB_HOST=your-rds-endpoint \
  -e DB_PASSWORD=yourpassword \
  your-dockerhub-username/todo-app:latest
```

---

## 📡 API Documentation

### Base URL
```
Production: http://your-alb-dns-name.region.elb.amazonaws.com
Local: http://localhost:3000
```

### Endpoints

#### Health Check
```http
GET /api/health
```
Returns application health and database connectivity status.

**Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "dbType": "mysql",
  "timestamp": "2026-01-26T12:00:00.000Z",
  "hostname": "ip-10-0-1-100"
}
```

#### Get All Todos
```http
GET /api/todos
```

**Response:**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "title": "Learn Docker",
      "description": "Complete Docker tutorial",
      "completed": false,
      "created_at": "2026-01-26T12:00:00.000Z"
    }
  ]
}
```

#### Create Todo
```http
POST /api/todos
Content-Type: application/json

{
  "title": "New Task",
  "description": "Optional description"
}
```

#### Update Todo
```http
PUT /api/todos/:id
Content-Type: application/json

{
  "title": "Updated title",
  "completed": true
}
```

#### Delete Todo
```http
DELETE /api/todos/:id
```

#### Clear Completed Todos
```http
DELETE /api/todos/completed/all
```

---

## 🧪 Testing

### Local Testing

```bash
# Make test script executable
chmod +x scripts/test-local.sh

# Run tests
./scripts/test-local.sh
```

### Manual Testing

```bash
# Health check
curl http://localhost:3000/api/health

# Get all todos
curl http://localhost:3000/api/todos

# Create todo
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Testing"}'

# Update todo
curl -X PUT http://localhost:3000/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'

# Delete todo
curl -X DELETE http://localhost:3000/api/todos/1
```

### Load Testing (Optional)

```bash
# Install Apache Bench
sudo yum install -y httpd-tools

# Test with 1000 requests, 10 concurrent
ab -n 1000 -c 10 http://your-alb-dns-name/api/health
```

---

## 🔧 Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `NODE_ENV` | Environment mode | `development` | No |
| `PORT` | Application port | `3000` | No |
| `DB_TYPE` | Database type (`mysql` or `postgresql`) | `mysql` | Yes |
| `DB_HOST` | Database hostname | `localhost` | Yes |
| `DB_PORT` | Database port | `3306` | No |
| `DB_NAME` | Database name | `tododb` | Yes |
| `DB_USER` | Database username | `admin` | Yes |
| `DB_PASSWORD` | Database password | - | Yes |

---

## 🐛 Troubleshooting

### Application won't start
```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs todo-app

# Restart
pm2 restart todo-app
```

### Database connection errors
```bash
# Test database connection
mysql -h your-rds-endpoint -u admin -p

# Check security groups
# App SG should allow outbound to DB SG on port 3306
```

### Docker container issues
```bash
# Check container logs
docker logs todo-app

# Enter container
docker exec -it todo-app sh

# Check environment variables
docker exec todo-app env
```

### Port 80 permission errors
```bash
# Allow Node to bind to port 80
sudo setcap 'cap_net_bind_service=+ep' $(which node)
```

---

## 📚 Learn More

### Docker Resources
- [Docker Official Docs](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### AWS Resources
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Amazon ECS Guide](https://docs.aws.amazon.com/ecs/)
- [Amazon RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)

### Node.js Resources
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

---

## 👤 Author

**Joel Livingstone Kofi Ackah**

- GitHub: [@KofiAckah](https://github.com/KofiAckah)
- LinkedIn: [Joel Ackah](https://linkedin.com/in/joel-ackah)

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Built for learning AWS 3-Tier Architecture
- Terraform infrastructure from [3tier-IaC](https://github.com/KofiAckah/3tier-IaC)
- Inspired by modern DevOps practices

---

## 🚀 Next Steps

1. ✅ Run locally with Docker Compose
2. ✅ Deploy to AWS using Terraform
3. ✅ Configure ALB health checks
4. ✅ Test with multiple EC2 instances
5. 🔲 Set up CI/CD pipeline (GitHub Actions)
6. 🔲 Add CloudWatch monitoring
7. 🔲 Implement caching (Redis)
8. 🔲 Add user authentication

---

**⭐ If this project helped you learn, please give it a star!**
