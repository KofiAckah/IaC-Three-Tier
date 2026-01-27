# 📖 Containerization Learning Guide

## Understanding Docker and Containerization for Your Todo App

This comprehensive guide explains containerization concepts, Docker fundamentals, and how they apply to your Todo App deployment.

---

## 📚 Table of Contents

1. [What is Containerization?](#what-is-containerization)
2. [Why Use Docker?](#why-use-docker)
3. [Docker Architecture](#docker-architecture)
4. [Key Docker Concepts](#key-docker-concepts)
5. [Dockerfile Explained](#dockerfile-explained)
6. [Docker Compose Deep Dive](#docker-compose-deep-dive)
7. [Best Practices](#best-practices)
8. [Production Deployment](#production-deployment)

---

## 🎯 What is Containerization?

**Containerization** is a method of packaging an application with all its dependencies, libraries, and configuration files into a single, portable unit called a **container**.

### Traditional Deployment vs Containerization

**Traditional (Without Containers):**
```
Your Computer                    Server
├── OS: Windows                  ├── OS: Linux
├── Node.js 18                   ├── Node.js 16 ❌ (version mismatch!)
├── MySQL 8                      ├── PostgreSQL ❌ (wrong database!)
└── Your App ✅                  └── Your App ❌ (doesn't work!)
```

**With Containers:**
```
Your Computer                    Server
├── Docker Engine                ├── Docker Engine
└── Container                    └── Container (exact same!)
    ├── Linux                        ├── Linux
    ├── Node.js 18                   ├── Node.js 18
    ├── All dependencies             ├── All dependencies
    └── Your App ✅                  └── Your App ✅
```

### Benefits

1. **Consistency**: "Works on my machine" → "Works everywhere"
2. **Isolation**: Each app runs in its own environment
3. **Portability**: Run the same container on any platform
4. **Efficiency**: Faster startup than virtual machines
5. **Scalability**: Easy to run multiple instances

---

## 🐳 Why Use Docker?

Docker is the most popular containerization platform. Here's why we use it for the Todo App:

### Problem: Different Environments

```bash
# Developer's laptop
- Windows 11
- Node.js 20
- MySQL 8.0
- Works perfectly! ✅

# Production server
- Amazon Linux
- Node.js 16 (old version)
- PostgreSQL (different DB)
- App crashes! ❌
```

### Solution: Docker Container

```bash
# Anywhere (laptop, server, cloud)
docker run todo-app

# Always has:
- Linux Alpine
- Node.js 18
- Exact dependencies
- Works everywhere! ✅
```

### Real-World Analogy

Think of Docker like **shipping containers**:
- A physical shipping container can hold anything
- It's standardized (same size, fittings)
- Can be moved by ship, train, or truck
- Contents are protected and isolated

Docker containers:
- Can hold any application
- Are standardized (Docker Engine runs them all)
- Can run on laptop, server, or cloud
- Apps are isolated and protected

---

## 🏗️ Docker Architecture

### Components

```
┌─────────────────────────────────────────────┐
│         Docker Client (CLI)                 │
│     $ docker run, docker build, etc.        │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│         Docker Daemon (dockerd)             │
│  - Manages images, containers, networks     │
│  - Builds images from Dockerfiles           │
│  - Runs containers                          │
└────────────────┬────────────────────────────┘
                 │
     ┌───────────┼───────────┐
     ▼           ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│Container│ │Container│ │Container│
│  (App)  │ │ (MySQL) │ │ (Nginx) │
└─────────┘ └─────────┘ └─────────┘
```

### How It Works

1. **Docker Client**: You type commands (`docker run`)
2. **Docker Daemon**: Processes commands, manages containers
3. **Docker Images**: Blueprint/template for containers
4. **Docker Containers**: Running instances of images

---

## 🔑 Key Docker Concepts

### 1. Images vs Containers

**Image** = Blueprint (like a class in programming)
- Read-only template
- Contains OS, app code, dependencies
- Versioned and reusable

**Container** = Running Instance (like an object)
- Created from an image
- Has its own filesystem, network, processes
- Can be started, stopped, deleted

```bash
# Image is like a recipe
docker images

# Container is like a meal made from recipe
docker ps

# You can make many meals (containers) from one recipe (image)
docker run todo-app    # Container 1
docker run todo-app    # Container 2
docker run todo-app    # Container 3
```

### 2. Dockerfile

A text file with instructions to build a Docker image:

```dockerfile
FROM node:18-alpine          # Start with Node.js base image
WORKDIR /app                 # Set working directory
COPY package*.json ./        # Copy package files
RUN npm install              # Install dependencies
COPY . .                     # Copy application code
CMD ["node", "server.js"]    # Command to run app
```

### 3. Docker Compose

Tool for defining and running **multi-container** applications:

```yaml
services:
  app:          # Todo application
  database:     # MySQL database
  nginx:        # Web server
```

Instead of running multiple `docker run` commands, just:
```bash
docker-compose up -d
```

### 4. Volumes

Persistent storage that survives container restarts:

```bash
# Without volume: Data lost when container stops!
docker run mysql

# With volume: Data persists!
docker run -v mysql_data:/var/lib/mysql mysql
```

### 5. Networks

Allow containers to communicate:

```bash
# Create network
docker network create todo-network

# Containers on same network can talk to each other
docker run --network todo-network --name mysql mysql
docker run --network todo-network --name app todo-app

# App can reach MySQL using hostname "mysql"
```

---

## 📝 Dockerfile Explained

Let's break down our Todo App Dockerfile:

```dockerfile
# ==================== Stage 1: Build Dependencies ====================
FROM node:18-alpine AS builder
```
**Explanation:**
- `FROM`: Start from official Node.js 18 image
- `alpine`: Lightweight Linux (5MB vs 900MB for full OS)
- `AS builder`: Name this stage for multi-stage build

```dockerfile
WORKDIR /app
```
**Explanation:**
- Set working directory to `/app`
- All subsequent commands run from here
- Like `cd /app` but permanent

```dockerfile
COPY package*.json ./
```
**Explanation:**
- Copy `package.json` and `package-lock.json`
- Done separately to leverage **Docker layer caching**
- If dependencies don't change, this layer is reused

```dockerfile
RUN npm ci --only=production
```
**Explanation:**
- `npm ci`: Clean install (faster, more reliable than `npm install`)
- `--only=production`: Skip dev dependencies
- Installs to `node_modules/`

```dockerfile
# ==================== Stage 2: Production Image ====================
FROM node:18-alpine
```
**Explanation:**
- Start fresh with clean Node.js image
- Previous stage's build tools are discarded
- Results in smaller final image

```dockerfile
WORKDIR /app
```
**Explanation:**
- Set working directory in final image

```dockerfile
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
```
**Explanation:**
- Create non-root user for security
- Containers shouldn't run as root
- Best practice for production

```dockerfile
COPY --from=builder /app/node_modules ./node_modules
```
**Explanation:**
- Copy `node_modules` from builder stage
- Only copy what we need
- Much smaller than copying entire builder stage

```dockerfile
COPY --chown=nodejs:nodejs . .
```
**Explanation:**
- Copy application code
- Set owner to nodejs user
- Ensures proper permissions

```dockerfile
ENV NODE_ENV=production \
    PORT=3000
```
**Explanation:**
- Set environment variables
- `NODE_ENV=production`: Optimizes Node.js
- `PORT=3000`: Default port

```dockerfile
EXPOSE 3000
```
**Explanation:**
- Document that container listens on port 3000
- Doesn't actually publish the port (done at runtime)

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"
```
**Explanation:**
- Automated health checking
- Checks `/api/health` every 30 seconds
- Container marked unhealthy if 3 consecutive failures
- Used by orchestrators (Docker, Kubernetes, ECS)

```dockerfile
USER nodejs
```
**Explanation:**
- Switch to non-root user
- All subsequent commands run as nodejs user
- Security best practice

```dockerfile
CMD ["node", "server.js"]
```
**Explanation:**
- Default command when container starts
- Starts the Node.js server
- Can be overridden at runtime

### Why Multi-Stage Build?

**Without Multi-Stage:**
```dockerfile
FROM node:18
COPY . .
RUN npm install
CMD ["node", "server.js"]
# Result: 950 MB image with dev dependencies
```

**With Multi-Stage:**
```dockerfile
FROM node:18-alpine AS builder
RUN npm ci --only=production
FROM node:18-alpine
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "server.js"]
# Result: 150 MB image, production-only
```

**Benefits:**
- 6x smaller image (150MB vs 950MB)
- Faster downloads and deployments
- No dev tools in production
- Better security (smaller attack surface)

---

## 🎼 Docker Compose Deep Dive

Our `docker-compose.yml` orchestrates multiple services:

```yaml
version: '3.8'
```
**Explanation:** Docker Compose file format version

### MySQL Service

```yaml
services:
  mysql:
    image: mysql:8.0
```
**Explanation:**
- Use official MySQL 8.0 image from Docker Hub
- No custom build needed

```yaml
    container_name: todo-mysql
```
**Explanation:**
- Give container a specific name
- Can reference as `todo-mysql` instead of random name

```yaml
    restart: unless-stopped
```
**Explanation:**
- Automatically restart if crashed
- Don't restart if manually stopped
- Useful for production

```yaml
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: tododb
      MYSQL_USER: admin
      MYSQL_PASSWORD: YourSecurePassword123!
```
**Explanation:**
- Configure MySQL through environment variables
- Creates database and user automatically
- **Warning:** Use secrets in production!

```yaml
    ports:
      - "3306:3306"
```
**Explanation:**
- Map host port 3306 to container port 3306
- Format: "host:container"
- Allows external access to MySQL

```yaml
    volumes:
      - mysql_data:/var/lib/mysql
```
**Explanation:**
- Persist MySQL data to named volume
- Data survives container restarts
- Can be backed up separately

```yaml
    networks:
      - todo-network
```
**Explanation:**
- Connect to custom network
- Allows communication with app container

```yaml
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 10
```
**Explanation:**
- Check if MySQL is actually ready (not just running)
- Prevents app from connecting too early
- Retries 10 times before marking unhealthy

### App Service

```yaml
  app:
    build:
      context: .
      dockerfile: Dockerfile
```
**Explanation:**
- Build from local Dockerfile
- `context: .` means current directory
- Different from `image:` which pulls from registry

```yaml
    depends_on:
      mysql:
        condition: service_healthy
```
**Explanation:**
- Start app only after MySQL is healthy
- Prevents connection errors
- Ensures proper startup order

```yaml
    environment:
      DB_HOST: mysql
```
**Explanation:**
- `mysql` is the hostname
- Docker DNS resolves it to MySQL container IP
- No hardcoded IPs needed!

### Networks

```yaml
networks:
  todo-network:
    driver: bridge
```
**Explanation:**
- Create custom bridge network
- Provides DNS resolution
- Isolates containers from other networks

### Volumes

```yaml
volumes:
  mysql_data:
    driver: local
```
**Explanation:**
- Define named volume
- Stored in `/var/lib/docker/volumes/`
- Can be backed up, moved, shared

---

## ⭐ Best Practices

### 1. Use .dockerignore

```
node_modules/
.git/
.env
*.log
```
**Why:** Faster builds, smaller images, no sensitive data

### 2. Multi-Stage Builds

**Do:**
```dockerfile
FROM node:18 AS builder
RUN npm install
FROM node:18-alpine
COPY --from=builder ...
```

**Don't:**
```dockerfile
FROM node:18
RUN npm install  # Bloated image
```

### 3. Layer Caching

**Efficient (dependencies cached):**
```dockerfile
COPY package*.json ./
RUN npm install
COPY . .  # Only rebuilds if code changes
```

**Inefficient (always reinstalls):**
```dockerfile
COPY . .  # Copies everything
RUN npm install  # Reinstalls even if unchanged
```

### 4. Security

```dockerfile
# ✅ Good: Non-root user
USER nodejs
CMD ["node", "server.js"]

# ❌ Bad: Running as root
CMD ["node", "server.js"]
```

### 5. Environment-Specific Configs

```bash
# Development
docker-compose up

# Production
docker-compose -f docker-compose.prod.yml up
```

---

## 🚀 Production Deployment

### AWS ECS (Elastic Container Service)

1. **Build and Push to ECR:**
```bash
# Build image
docker build -t todo-app .

# Tag for ECR
docker tag todo-app:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/todo-app:latest

# Push to ECR
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/todo-app:latest
```

2. **Create ECS Task Definition:**
```json
{
  "family": "todo-app",
  "containerDefinitions": [{
    "name": "app",
    "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/todo-app:latest",
    "memory": 512,
    "portMappings": [{"containerPort": 3000}],
    "environment": [
      {"name": "DB_HOST", "value": "rds-endpoint"}
    ]
  }]
}
```

### Docker on EC2

```bash
# On EC2 instance
sudo yum install -y docker
sudo systemctl start docker

# Run container
docker run -d \
  --name todo-app \
  --restart unless-stopped \
  -p 80:3000 \
  -e DB_HOST=${RDS_ENDPOINT} \
  todo-app:latest
```

### Kubernetes (Advanced)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-app
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: app
        image: todo-app:latest
        ports:
        - containerPort: 3000
```

---

## 📖 Learning Path

### Beginner
1. ✅ Run with Docker Compose locally
2. ✅ Understand Dockerfile instructions
3. ✅ Modify code and rebuild
4. ✅ Use volumes for data persistence

### Intermediate
1. Build custom images
2. Push to Docker Hub
3. Deploy to AWS EC2 with Docker
4. Use Docker networks

### Advanced
1. Multi-stage builds optimization
2. Deploy to AWS ECS/Fargate
3. Kubernetes orchestration
4. CI/CD with Docker

---

## 🎯 Practice Exercises

### Exercise 1: Modify the App
```bash
# 1. Change the app title in views/index.ejs
# 2. Rebuild the image
docker-compose build

# 3. Restart containers
docker-compose up -d

# 4. Verify changes at http://localhost:3000
```

### Exercise 2: Environment Variables
```bash
# Add a new environment variable
docker run -e APP_NAME="My Todo App" todo-app

# Access in code:
process.env.APP_NAME
```

### Exercise 3: Volume Backup
```bash
# Backup MySQL data
docker run --rm \
  -v app_mysql_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz /data
```

---

## 🔗 Resources

- [Docker Official Docs](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Congratulations!** You now understand containerization and Docker fundamentals. 🎉

Ready to deploy? Check out [QUICKSTART.md](QUICKSTART.md) to get started!
