# Docker Hub Setup for Todo App

## Step 1: Build and Test Docker Image Locally

```bash
cd /home/joel-livingstone-kofi-ackah/Desktop/Assignment/IaC-Tier/App

# Build the Docker image
docker build -t kofiackah/todo-app:latest .

# Test it locally (optional)
docker run -d -p 3000:3000 \
  -e DB_HOST=your-test-db \
  -e DB_NAME=tododb \
  -e DB_USER=admin \
  -e DB_PASSWORD=your-password \
  kofiackah/todo-app:latest
```

## Step 2: Login to Docker Hub

```bash
# Login to Docker Hub (you'll be prompted for your password)
docker login
# Enter your Docker Hub username: kofiackah
# Enter your Docker Hub password: [your password]
```

## Step 3: Push Image to Docker Hub

```bash
# Push the image to Docker Hub
docker push kofiackah/todo-app:latest
```

## Step 4: Verify on Docker Hub

Go to: https://hub.docker.com/r/kofiackah/todo-app

You should see your image there!

## Step 5: Deploy Infrastructure

```bash
cd /home/joel-livingstone-kofi-ackah/Desktop/Assignment/IaC-Tier/Infrastructure

# Apply the infrastructure changes
terraform apply -var-file="dev.tfvars"
```

The EC2 instances will now pull your image from Docker Hub (just like your friend's phpMyAdmin approach)!

## Notes:

- **Image name**: `kofiackah/todo-app:latest`
- Change `kofiackah` to your actual Docker Hub username if different
- Update the script if you use a different username or image name
- The infrastructure is now configured to pull from Docker Hub
- Much faster than building on each EC2 instance!

## How it Works (Like Your Friend):

```
Friend's Approach:          Your Approach:
└─ phpMyAdmin              └─ Todo App
   └─ docker pull             └─ docker pull
      phpmyadmin:latest          kofiackah/todo-app:latest
```

Both pull pre-built images from Docker Hub! 🎉
