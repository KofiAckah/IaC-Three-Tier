# AWS Architecture Diagram Generator

This folder contains Python scripts to generate visual diagrams of the 3-tier AWS architecture.

## Prerequisites

Install Graphviz (required for diagrams library):

### Linux (Ubuntu/Debian)
```bash
sudo apt-get install graphviz
```

### macOS
```bash
brew install graphviz
```

### Windows
Download and install from: https://graphviz.org/download/

## Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

Or:
```bash
pip install diagrams graphviz
```

## Generate Diagram

Run the Python script:
```bash
python3 generate_diagram.py
```

Or make it executable:
```bash
chmod +x generate_diagram.py
./generate_diagram.py
```

## Output

The script generates two files:
- `aws_3tier_architecture.png` - PNG image
- `aws_3tier_architecture.pdf` - PDF vector format

## Architecture Components

The diagram includes:

### Network Layer
- VPC (10.0.0.0/16)
- Public Subnets (2 AZs)
- Private App Subnets (2 AZs)
- Private DB Subnets (2 AZs)
- Internet Gateway
- NAT Gateway
- Route Tables

### Security Layer
- Web Security Group (ALB - Port 80/443)
- App Security Group (EC2 - Port 80)
- DB Security Group (RDS - Port 3306)

### Presentation Layer
- Application Load Balancer (Multi-AZ)
- Target Group with health checks

### Application Layer
- Auto Scaling Group (Min: 1, Desired: 2, Max: 4)
- EC2 Instances running Todo App in Docker
- Docker image: livingstoneackah/todo-app:latest

### Data Layer
- RDS MySQL 8.0 (Multi-AZ)
- Database: tododb
- Instance: db.t3.micro

## Traffic Flow

1. **Inbound**: Users → IGW → ALB → EC2 (Docker) → RDS
2. **Outbound**: EC2 → NAT Gateway → IGW → Docker Hub
3. **Database**: EC2 ↔ RDS MySQL (Private)

## Customization

Edit `generate_diagram.py` to:
- Change colors and styles
- Add/remove components
- Modify labels and descriptions
- Change output format (png, pdf, svg, jpg)
