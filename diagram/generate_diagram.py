#!/usr/bin/env python3
"""
AWS 3-Tier Architecture Diagram Generator
Generates visual diagram based on Infrastructure as Code setup

Architecture:
- Network Layer: VPC, Subnets, IGW, NAT Gateway
- Security Layer: Security Groups
- Presentation Layer: Application Load Balancer
- Application Layer: Auto Scaling Group with EC2 instances (Docker Todo App)
- Data Layer: RDS MySQL Database
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import VPC, PublicSubnet, PrivateSubnet, InternetGateway, NATGateway, RouteTable, ELB
from diagrams.aws.compute import EC2, AutoScaling
from diagrams.aws.database import RDS
from diagrams.generic.network import Firewall
from diagrams.onprem.client import Users

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
    "splines": "ortho",
    "nodesep": "1.0",
    "ranksep": "1.5",
    "fontname": "Sans-Serif"
}

node_attr = {
    "fontsize": "12",
    "fontname": "Sans-Serif"
}

edge_attr = {
    "fontsize": "10",
    "fontname": "Sans-Serif"
}

with Diagram(
    "3-Tier AWS Architecture - IaC Project",
    show=False,
    direction="TB",
    filename="aws_3tier_architecture",
    outformat=["png", "pdf"],
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr
):
    # External users
    users = Users("Internet Users")

    with Cluster("AWS Region: eu-central-1"):
        with Cluster("VPC (10.0.0.0/16)"):
            # Internet Gateway
            igw = InternetGateway("Internet Gateway")
            
            with Cluster("Availability Zone 1a"):
                with Cluster("Public Subnet 1"):
                    nat_gw = NATGateway("NAT Gateway")
                    alb_1a = ELB("Application\nLoad Balancer")
                
                with Cluster("Private App Subnet 1"):
                    asg_1a = AutoScaling("Auto Scaling\nGroup")
                    ec2_1a = EC2("Todo App\n(Docker)")
                
                with Cluster("Private DB Subnet 1"):
                    rds_1a = RDS("RDS MySQL\nPrimary")
            
            with Cluster("Availability Zone 1b"):
                with Cluster("Public Subnet 2"):
                    alb_1b = ELB("Application\nLoad Balancer")
                
                with Cluster("Private App Subnet 2"):
                    asg_1b = AutoScaling("Auto Scaling\nGroup")
                    ec2_1b = EC2("Todo App\n(Docker)")
                
                with Cluster("Private DB Subnet 2"):
                    rds_1b = RDS("RDS MySQL\nStandby")
            
            # Security Groups
            with Cluster("Security Groups"):
                web_sg = Firewall("Web SG\n(Port 80/443)")
                app_sg = Firewall("App SG\n(Port 80)")
                db_sg = Firewall("DB SG\n(Port 3306)")

    # Traffic Flow - Internet to ALB
    users >> Edge(label="HTTPS/HTTP", color="darkgreen") >> igw
    igw >> Edge(label="HTTP 80", color="green") >> alb_1a
    igw >> Edge(label="HTTP 80", color="green") >> alb_1b

    # ALB to EC2 instances
    alb_1a >> Edge(label="HTTP 80", color="blue") >> ec2_1a
    alb_1b >> Edge(label="HTTP 80", color="blue") >> ec2_1b
    alb_1a >> Edge(color="blue", style="dashed") >> ec2_1b
    alb_1b >> Edge(color="blue", style="dashed") >> ec2_1a

    # EC2 to RDS
    ec2_1a >> Edge(label="MySQL 3306", color="orange") >> rds_1a
    ec2_1b >> Edge(label="MySQL 3306", color="orange") >> rds_1b
    ec2_1a >> Edge(color="orange", style="dashed") >> rds_1b
    ec2_1b >> Edge(color="orange", style="dashed") >> rds_1a

    # Outbound traffic through NAT
    ec2_1a >> Edge(label="Docker Hub", color="gray", style="dotted") >> nat_gw
    ec2_1b >> Edge(color="gray", style="dotted") >> nat_gw
    nat_gw >> Edge(color="gray", style="dotted") >> igw

    # Security Group associations
    alb_1a - Edge(color="red", style="dotted") - web_sg
    alb_1b - Edge(color="red", style="dotted") - web_sg
    ec2_1a - Edge(color="red", style="dotted") - app_sg
    ec2_1b - Edge(color="red", style="dotted") - app_sg
    rds_1a - Edge(color="red", style="dotted") - db_sg
    rds_1b - Edge(color="red", style="dotted") - db_sg

print("✅ Diagram generated successfully!")
print("📁 Output files:")
print("   - aws_3tier_architecture.png")
print("   - aws_3tier_architecture.pdf")
