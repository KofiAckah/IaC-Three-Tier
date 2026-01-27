# 🎯 Quick Start Guide - Todo App with Docker

This guide will help you get the Todo App running locally with Docker in **5 minutes**!

---

## ⚡ Prerequisites

Make sure you have installed:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (includes Docker and Docker Compose)
- A terminal/command prompt

**Verify installation:**
```bash
docker --version
docker-compose --version
```

---

## 🚀 Step-by-Step Tutorial

### Step 1: Navigate to App Directory

```bash
cd /home/joel-livingstone-kofi-ackah/Desktop/Assignment/IaC-Tier/App
```

### Step 2: Start the Application with Docker Compose

```bash
# Start all services (app + database)
docker-compose up -d

# Expected output:
# ✅ Creating network "app_todo-network" ... done
# ✅ Creating volume "app_mysql_data" ... done
# ✅ Creating todo-mysql ... done
# ✅ Creating todo-app ... done
```

**What just happened?**
- Docker downloaded MySQL and Node.js images
- Created a network for containers to communicate
- Started MySQL database on port 3306
- Started Todo App on port 3000
- Automatically connected app to database

### Step 3: Check if Everything is Running

```bash
docker-compose ps

# You should see:
# NAME         STATUS    PORTS
# todo-app     Up        0.0.0.0:3000->3000/tcp
# todo-mysql   Up        0.0.0.0:3306->3306/tcp
```

### Step 4: View Logs

```bash
# View app logs
docker-compose logs -f app

# You should see:
# ✅ Database connection successful
# ✅ Database tables initialized
# 🚀 Todo App Server Started
# 📍 Server URL: http://localhost:3000
```

### Step 5: Access the Application

Open your browser and go to:
```
http://localhost:3000
```

You should see the beautiful Todo App interface! 🎉

### Step 6: Test the API

Open a new terminal and test the health endpoint:

```bash
# Test health check
curl http://localhost:3000/api/health

# Expected response:
# {
#   "status": "healthy",
#   "database": "connected",
#   "dbType": "mysql"
# }
```

---

## 🎨 Using the Application

1. **Add a Todo**: Type a task in the input field and click "Add Todo"
2. **Mark as Complete**: Click the checkbox next to a todo
3. **Delete a Todo**: Click the "Delete" button
4. **Filter Todos**: Use All/Active/Completed buttons
5. **Clear Completed**: Remove all completed tasks at once

---

## 🛠️ Understanding Docker Compose

Let's break down what `docker-compose.yml` does:

```yaml
services:
  mysql:                    # Database service
    image: mysql:8.0        # Uses official MySQL image
    ports:
      - "3306:3306"         # Expose MySQL port
    volumes:
      - mysql_data:/var/lib/mysql  # Persist data
    
  app:                      # Todo app service
    build: .                # Build from Dockerfile
    ports:
      - "3000:3000"         # Expose app port
    environment:            # Configuration
      DB_HOST: mysql        # Connect to mysql service
      DB_PASSWORD: YourSecurePassword123!
    depends_on:             # Wait for MySQL
      mysql:
        condition: service_healthy
```

**Key Concepts:**
- **Services**: Individual containers (app, database)
- **Networks**: Automatic DNS (app can reach "mysql" by name)
- **Volumes**: Persistent storage (database data survives restarts)
- **Health Checks**: Wait for services to be ready

---

## 🔍 Exploring Docker Commands

### View Running Containers

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs

# Just the app
docker-compose logs app

# Follow logs (real-time)
docker-compose logs -f app
```

### Execute Commands in Container

```bash
# Access app container shell
docker exec -it todo-app sh

# Inside the container, try:
node --version
ls -la
env | grep DB_
exit
```

### Restart Services

```bash
# Restart just the app
docker-compose restart app

# Restart everything
docker-compose restart
```

### Stop and Remove Everything

```bash
# Stop containers but keep data
docker-compose down

# Stop and remove all data
docker-compose down -v
```

---

## 🐳 Understanding the Dockerfile

Our Dockerfile uses **multi-stage builds** for efficiency:

```dockerfile
# Stage 1: Build dependencies
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Create production image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER nodejs  # Security: run as non-root
CMD ["node", "server.js"]
```

**Why multi-stage?**
- **Smaller image**: Only production files in final image
- **Faster builds**: Caching of npm install layer
- **More secure**: No build tools in production image

---

## 📊 Monitoring Your Containers

### Check Resource Usage

```bash
docker stats

# Shows CPU, Memory, Network usage for each container
```

### Inspect Container Details

```bash
docker inspect todo-app

# View all configuration, networks, volumes, etc.
```

### View Container Processes

```bash
docker-compose top

# Shows running processes inside containers
```

---

## 🧪 Testing the Application

### Run the Test Script

```bash
# Make executable
chmod +x scripts/test-local.sh

# Run tests
./scripts/test-local.sh
```

This will:
- Test health endpoint
- Create a todo
- Update a todo
- Delete a todo
- Verify all API endpoints work

---

## 🔧 Common Tasks

### Rebuild After Code Changes

```bash
# Rebuild and restart
docker-compose up -d --build

# Just rebuild without starting
docker-compose build
```

### Scale the Application

```bash
# Run 3 instances of the app (for learning load balancing)
docker-compose up -d --scale app=3

# Note: You'll need to add port mapping for multiple instances
```

### Access Database Directly

```bash
# Connect to MySQL
docker exec -it todo-mysql mysql -u admin -pYourSecurePassword123!

# Inside MySQL:
SHOW DATABASES;
USE tododb;
SHOW TABLES;
SELECT * FROM todos;
exit
```

### Clean Up Everything

```bash
# Stop and remove containers, networks
docker-compose down

# Also remove volumes (clears database)
docker-compose down -v

# Remove all unused Docker resources
docker system prune -a
```

---

## 🔄 Switching to PostgreSQL

Want to try PostgreSQL instead of MySQL?

```bash
# Stop current setup
docker-compose down

# Start with PostgreSQL
docker-compose --profile postgres up -d

# Update app environment
docker-compose exec app sh
# Inside container:
echo "DB_TYPE=postgresql" >> .env
echo "DB_PORT=5432" >> .env
exit

# Restart app
docker-compose restart app
```

---

## 🚀 Next Steps

### 1. **Modify the Code**
   - Change `views/index.ejs` to customize UI
   - Add new routes in `server.js`
   - Rebuild: `docker-compose up -d --build`

### 2. **Persist Your Data**
   - Data is saved in Docker volumes
   - View volumes: `docker volume ls`
   - Backup: `docker run --rm -v app_mysql_data:/data -v $(pwd):/backup busybox tar czf /backup/backup.tar.gz /data`

### 3. **Deploy to AWS**
   - Follow [TERRAFORM-INTEGRATION.md](TERRAFORM-INTEGRATION.md)
   - Push image to Docker Hub or AWS ECR
   - Run on EC2 with Docker installed

### 4. **Add Nginx Reverse Proxy**
   ```bash
   docker-compose --profile nginx up -d
   # Access through: http://localhost
   ```

---

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Find what's using port 3000
sudo lsof -i :3000
# or
netstat -tulpn | grep 3000

# Kill the process or change port in docker-compose.yml
```

### Database Connection Failed

```bash
# Check if MySQL is healthy
docker-compose ps

# View MySQL logs
docker-compose logs mysql

# Restart MySQL
docker-compose restart mysql
```

### App Won't Start

```bash
# View detailed logs
docker-compose logs app

# Check if node_modules exist
docker exec todo-app ls -la node_modules

# Rebuild completely
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 📚 Learning Resources

### Docker
- [Docker Official Tutorial](https://docs.docker.com/get-started/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Node.js
- [Express.js Guide](https://expressjs.com/en/starter/installing.html)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

### Databases
- [MySQL Tutorial](https://dev.mysql.com/doc/mysql-getting-started/en/)
- [PostgreSQL Tutorial](https://www.postgresql.org/docs/current/tutorial.html)

---

## ✅ Checklist

- [ ] Docker Desktop installed and running
- [ ] Navigated to App directory
- [ ] Ran `docker-compose up -d`
- [ ] Verified containers are running with `docker-compose ps`
- [ ] Accessed http://localhost:3000 in browser
- [ ] Created your first todo!
- [ ] Tested API with curl
- [ ] Viewed logs with `docker-compose logs -f app`
- [ ] Explored container with `docker exec -it todo-app sh`
- [ ] Ran test script successfully

---

## 🎓 What You Learned

By completing this guide, you've learned:

1. ✅ **Docker Basics**: Images, containers, volumes, networks
2. ✅ **Docker Compose**: Multi-container applications
3. ✅ **Containerization**: Packaging apps with dependencies
4. ✅ **Service Orchestration**: Managing app + database
5. ✅ **Health Checks**: Ensuring services are ready
6. ✅ **Persistent Storage**: Using volumes for data
7. ✅ **Networking**: Container-to-container communication
8. ✅ **Debugging**: Logs, exec, inspect commands

---

## 🎉 Congratulations!

You've successfully:
- Containerized a full-stack Node.js application
- Set up a multi-container environment with Docker Compose
- Learned essential Docker commands and concepts
- Built a foundation for deploying to AWS

**Ready for the next challenge?** Deploy to AWS! 🚀

Check out [TERRAFORM-INTEGRATION.md](TERRAFORM-INTEGRATION.md) for AWS deployment.

---

**Questions? Issues?** Open an issue on GitHub!

**Happy Learning! 🐳**
