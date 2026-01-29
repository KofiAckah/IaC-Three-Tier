# 🎨 AWS Architecture Diagram Guide

## 📁 Available Diagram Formats

Your architecture is available in **3 formats**:

| File | Type | Best For | Editable? |
|------|------|----------|-----------|
| `aws_3tier_architecture.drawio` | Draw.io | Editing, customization | ✅ Yes |
| `aws_3tier_architecture.png` | Image | Presentations, documentation | ❌ No |
| `aws_3tier_architecture.pdf` | PDF | Printing, formal reports | ❌ No |

---

## 🖼️ Draw.io Diagram (Recommended for Editing)

### **Open Online (No Installation)**

1. Go to: **https://app.diagrams.net** (or https://draw.io)
2. Click **"Open Existing Diagram"**
3. Select **"Open from Device"**
4. Choose: `aws_3tier_architecture.drawio`
5. Edit and save!

### **Open in VS Code**

**Install Extension:**
```bash
code --install-extension hediet.vscode-drawio
```

**Then:**
- Click on `aws_3tier_architecture.drawio` in VS Code
- Edit directly in the editor!

### **Open with Desktop App**

**Download:** https://github.com/jgraph/drawio-desktop/releases

**Then:**
```bash
# On Ubuntu/Debian
sudo dpkg -i drawio-amd64-*.deb

# Launch
drawio aws_3tier_architecture.drawio
```

---

## 🎯 What's in the Diagram?

### **Architecture Components:**

#### **Network Layer:**
- ✅ VPC (10.0.0.0/16)
- ✅ Internet Gateway
- ✅ 2 NAT Gateways (Multi-AZ)
- ✅ 2 Availability Zones (eu-central-1a, eu-central-1b)

#### **Subnets (6 Total):**
- ✅ 2 Public Subnets (10.0.0.0/20, 10.0.16.0/20)
- ✅ 2 Private App Subnets (10.0.32.0/20, 10.0.48.0/20)
- ✅ 2 Private DB Subnets (10.0.64.0/20, 10.0.80.0/20)

#### **Compute Layer:**
- ✅ Application Load Balancer (spanning both AZs)
- ✅ Auto Scaling Groups
- ✅ EC2 Instances (Docker Todo App)

#### **Database Layer:**
- ✅ RDS MySQL Multi-AZ (Primary + Standby)

#### **Security:**
- ✅ Web Security Group (HTTP/HTTPS/ICMP)
- ✅ App Security Group (HTTP/SSH/ICMP)
- ✅ DB Security Group (MySQL 3306)

### **Traffic Flows:**

| Flow | Color | Description |
|------|-------|-------------|
| 🟢 Green Solid | HTTPS/HTTP | Internet → IGW → ALB |
| 🔵 Blue Solid | HTTP 80 | ALB → EC2 Instances |
| 🟠 Orange Solid | MySQL 3306 | EC2 → RDS Database |
| ⚪ Gray Dashed | Docker Hub | EC2 → NAT → Internet |

---

## 🔧 Python Diagram (Auto-Generated)

### **Regenerate Diagram:**

```bash
cd diagram

# Activate virtual environment
source venv/bin/activate

# Generate new diagram
python3 generate_diagram.py
```

**Output:**
- `aws_3tier_architecture.png` (updated)
- `aws_3tier_architecture.pdf` (updated)

### **When to Use Python Generator:**

✅ **Quick updates** when infrastructure changes  
✅ **Consistent styling** with diagrams library  
✅ **Automated documentation** in CI/CD pipelines  

### **When to Use Draw.io:**

✅ **Custom styling** and colors  
✅ **Presentations** with animations  
✅ **Detailed annotations** and notes  
✅ **Manual adjustments** for clarity  

---

## 📸 Viewing the Diagrams

### **PNG Image:**

```bash
# Open in default image viewer
xdg-open aws_3tier_architecture.png

# Or use specific viewer
eog aws_3tier_architecture.png      # GNOME
gwenview aws_3tier_architecture.png # KDE
feh aws_3tier_architecture.png      # Lightweight
```

### **PDF Document:**

```bash
# Open in default PDF viewer
xdg-open aws_3tier_architecture.pdf

# Or use specific viewer
evince aws_3tier_architecture.pdf   # GNOME
okular aws_3tier_architecture.pdf   # KDE
```

---

## 🎓 Tips for Editing Draw.io Diagram

### **Add New Components:**

1. **Click** on the left sidebar
2. **Search** "AWS" in the shape library
3. **Drag** AWS icons onto canvas
4. **Connect** with arrows

### **AWS Icon Library:**

The diagram uses official AWS architecture icons:
- **Compute:** EC2, Auto Scaling, Lambda
- **Network:** VPC, ALB, NLB, Route 53
- **Database:** RDS, DynamoDB, ElastiCache
- **Security:** Security Groups, IAM, KMS

### **Change Colors:**

1. Select element
2. Right panel → **Style**
3. Modify **Fill Color** or **Stroke Color**

### **Export Options:**

- **PNG:** File → Export as → PNG
- **PDF:** File → Export as → PDF
- **SVG:** File → Export as → SVG
- **HTML:** File → Export as → HTML

---

## 🚀 Quick Actions

### **Update Infrastructure & Diagram:**

```bash
# 1. Update Terraform infrastructure
cd ../Infrastructure
terraform apply -var-file="dev.tfvars"

# 2. Regenerate Python diagram
cd ../diagram
source venv/bin/activate
python3 generate_diagram.py

# 3. Manually update draw.io if needed
xdg-open aws_3tier_architecture.drawio
```

### **Create Presentation:**

```bash
# Export draw.io to PNG with transparent background
# File → Export as → PNG → Transparent Background

# Use in your presentation software:
# - Google Slides
# - PowerPoint
# - LibreOffice Impress
```

---

## 📋 Diagram Checklist

Use this checklist when presenting your architecture:

- [ ] **VPC clearly labeled** with CIDR block
- [ ] **2 Availability Zones** shown
- [ ] **All 6 subnets** with CIDR blocks
- [ ] **Internet Gateway** connected to VPC
- [ ] **2 NAT Gateways** (one per AZ) - Multi-AZ HA
- [ ] **ALB** spanning public subnets
- [ ] **EC2 instances** in private app subnets
- [ ] **RDS Multi-AZ** in private DB subnets
- [ ] **Security Groups** with ports listed
- [ ] **Traffic flows** with arrows and labels
- [ ] **Legend** explaining colors/symbols
- [ ] **Title** with environment name

---

## 🎨 Customization Ideas

### **For Different Environments:**

**Dev Environment (Current):**
- Green borders for subnets
- "DEV" watermark

**Staging Environment:**
- Yellow borders
- "STAGING" watermark

**Production Environment:**
- Red borders for critical components
- "PRODUCTION" watermark
- Add CloudWatch, CloudTrail icons

### **Add More Detail:**

- ✨ Route Tables with route entries
- ✨ EIP addresses for NAT Gateways
- ✨ CloudWatch alarms
- ✨ S3 buckets for logs
- ✨ Bastion host (if added back)
- ✨ VPC Peering (for multi-VPC)

---

## 💡 Best Practices

### **Color Coding:**

| Color | Use For |
|-------|---------|
| 🟢 Green | Public subnets, internet-facing |
| 🔵 Blue | Private app subnets |
| 🟣 Purple | Private DB subnets |
| 🔴 Red | Security groups, firewalls |
| ⚫ Black/Gray | Internal traffic, management |

### **Labeling:**

✅ **DO:**
- Include CIDR blocks on subnets
- Label all connections (port numbers)
- Add AZ names to subnets
- Show resource counts (2x EC2, etc.)

❌ **DON'T:**
- Clutter with too much text
- Use unclear abbreviations
- Forget to update after changes
- Mix different icon styles

---

## 🔗 Useful Resources

- **Draw.io Documentation:** https://www.diagrams.net/doc/
- **AWS Architecture Icons:** https://aws.amazon.com/architecture/icons/
- **Python Diagrams Library:** https://diagrams.mingrammer.com/
- **AWS Well-Architected:** https://aws.amazon.com/architecture/well-architected/

---

## 🎯 Summary

You now have **3 diagram formats**:

1. **`aws_3tier_architecture.drawio`** → Edit at https://app.diagrams.net
2. **`aws_3tier_architecture.png`** → Use in presentations
3. **`aws_3tier_architecture.pdf`** → Print or formal reports

**Your architecture is production-ready with:**
- ✅ Multi-AZ high availability
- ✅ Proper security group isolation
- ✅ NAT Gateways for private subnet internet access
- ✅ Load balancing across availability zones
- ✅ Auto Scaling for resilience
- ✅ RDS Multi-AZ for database redundancy

Perfect for your assignment! 🎉
