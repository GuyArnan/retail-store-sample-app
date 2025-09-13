# Retail Store Sample App - Kubernetes kubeadm Cluster Project

![Banner](./docs/images/banner.png) 

<div align="center">
  <div align="center"> 

![GitHub License](https://img.shields.io/github/license/LondheShubham153/retail-store-sample-app?color=green)

  </div>

  <strong>
  <h2>Kubernetes kubeadm Cluster Project</h2>
  </strong>
</div>

This is a comprehensive Kubernetes project designed to teach students how to deploy a complete microservices application on a **kubeadm cluster**. The project covers cluster setup, infrastructure provisioning with Terraform, CI/CD pipelines, and manual deployment using Helm charts.

## 📋 Project Overview

- Set up a **multi-node kubeadm cluster** (1 control plane + 2 worker nodes)
- Provision infrastructure using **Terraform**
- Implement **CI/CD pipelines** with GitHub Actions
- Deploy applications using **Helm charts** with manual deployment
- Manage container images with **Amazon ECR**
- Use **Ingress Controller** for external access

## 🏗️ Architecture

The retail store application demonstrates a modern microservices architecture deployed on a kubeadm Kubernetes cluster:

![Architecture](./docs/images/architecture.png)

### **Application Components**

| Service | Language | Description | Dependencies |
|---------|----------|-------------|--------------|
| **UI** | Java | Store user interface | Catalog, Cart, Orders |
| **Catalog** | Go | Product catalog API | PostgreSQL |
| **Cart** | Java | Shopping cart API | Redis, DynamoDB |
| **Orders** | Java | Order management API | PostgreSQL |
| **Checkout** | Node.js | Checkout orchestration API | Cart, Orders, RabbitMQ |

### **Infrastructure Components**

![Application Architecture](./docs/images/application-architecture.png)

The infrastructure follows cloud-native best practices:
- **Microservices**: Each component is developed and deployed independently
- **Containerization**: All services run as containers on Kubernetes
- **Infrastructure as Code**: All AWS resources defined using Terraform
- **CI/CD**: Automated build and deployment pipelines with GitHub Actions
- **Manual Deployment**: Helm charts for application packaging and deployment

## 🛠️ Prerequisites

Students need to install:
- **AWS CLI** (v2+) - [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **Terraform** (1.0+) - [Install Guide](https://developer.hashicorp.com/terraform/install)
- **kubectl** (1.28+) - [Install Guide](https://kubernetes.io/docs/tasks/tools/)
- **Docker** (20.0+) - [Install Guide](https://docs.docker.com/get-docker/)
- **Helm** (3.0+) - [Install Guide](https://helm.sh/docs/intro/install/)
- **Git** (2.0+) - [Install Guide](https://git-scm.com/downloads)

### **Quick Installation Scripts**

<details>
<summary><strong>🔧 One-Click Installation</strong></summary>

```bash
#!/bin/bash
# Install all prerequisites

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# kubectl
curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installations
aws --version
terraform --version
kubectl version --client
docker --version
helm version
```

</details>

## 📚 Project Structure

```
├── terraform/           # Infrastructure as Code
├── src/                # Application source code
│   ├── ui/             # Java frontend
│   ├── catalog/        # Go catalog API
│   ├── cart/           # Java cart API
│   ├── orders/         # Java orders API
│   └── checkout/       # Node.js checkout API
├── scripts/            # Cluster setup scripts 
├── .github/workflows/  # CI/CD pipelines 
└── docs/               # Documentation
```

## 🚀 Complete Implementation Guide

## **Phase 1: Infrastructure Setup**

### **Step 1.1: Configure AWS Credentials**

```bash
# Configure AWS CLI with your credentials
aws configure
```

### **Step 1.2: Terraform Infrastructure**

**Your Task**: Create Terraform configuration to provision AWS infrastructure for your kubeadm cluster.

#### **Required Infrastructure Components:**

1. **VPC and Networking**:
   - VPC with **public subnets** (required)
   - **Private subnets** (bonus challenge - see below)
   - Internet Gateway (required)
   - NAT Gateway (required if using private subnets)
   - Route tables and associations
   - DNS resolution configuration

2. **Security Groups**:
   - **Control Plane Node**: SSH (22), Kubernetes API (6443), etcd (2379-2380), Kubelet API (10250), CNI ports
   - **Worker Nodes**: SSH (22), Kubelet API (10250), CNI ports

3. **EC2 Instances**:
   - **Control Plane**: t2.medium, Ubuntu 
   - **Worker Nodes**: t2.medium each, Ubuntu 
   - User data scripts to install Docker and kubeadm (Can also be AMI)
   - **Deploy on public subnets** for easier setup and access

4. **Additional Resources**:
   - IAM roles for ECR access
   - ECR repositories for all 5 services
   - Application Load Balancer (Can be set up later)

#### **🎯 Deployment Strategy - Public vs Private Subnets**

**📌 Main Requirement: Public Subnet Deployment**
- Deploy all cluster nodes on **public subnets** for easier setup
- Direct internet access for nodes simplifies configuration
- Easier troubleshooting and access during development
- Suitable for learning and development environments

**🏆 Bonus Challenge: Private Subnet Deployment**
- Deploy worker nodes on **private subnets** for enhanced security
- Control plane can remain on public subnet for easier access
- Requires NAT Gateway for outbound internet access
- Demonstrates production-ready security practices
- **Extra points** for implementing this advanced configuration

**Security Considerations**:
- Public subnets: Use security groups and SSH key pairs for access control
- Private subnets: Implement bastion host or VPN for secure access

#### **Terraform Structure**:

**Your Task**: Design and implement your own Terraform structure. Consider using **modules** to organize your code for better maintainability and reusability.

**Suggestions**:
- Use **modules** for different components (VPC, EC2, ECR, etc.)
- Organize files logically (by resource type, environment, or functionality)
- Consider using **locals** for computed values and common configurations
- Implement **variables** for customization and reusability
- Define **outputs** for values needed by other components


**Best Practices**:
- Use meaningful resource names and tags
- Implement proper state management and locking
- Follow Terraform coding standards


## **Phase 2: kubeadm Cluster Setup**

### **Step 2.1: Cluster Setup Scripts**

**Your Task**: Create shell scripts to set up the kubeadm Kubernetes cluster.

***You can skip this phase if you used an AMI.***

#### **Required Scripts**:

1. **`scripts/install-prerequisites.sh`**:
   - Install Docker, kubeadm, kubelet, kubectl
   - Configure Docker daemon
   - Set up kernel modules and sysctl settings
   - Disable swap

2. **`scripts/setup-control-plane.sh`**:
   - Initialize kubeadm cluster
   - Install CNI plugin (Calico recommended)
   - Configure kubectl
   - Generate join command for worker nodes

3. **`scripts/setup-worker-nodes.sh`**:
   - Install Docker and kubeadm
   - Join cluster using token from control plane
   - Verify node registration


#### **Expected Results**:
```bash
kubectl get nodes
# Should show 3 nodes (1 control plane + 2 workers) all in Ready state

kubectl get pods --all-namespaces
# Should show core DNS pods and CNI pods running
```

## **Phase 3: CI/CD Pipeline**

### **Step 3.1: ECR Setup**

**Your Task**: Create Amazon ECR repositories (with Terraform) and configure GitHub Actions for automated builds.

#### **ECR Repositories**:
- retail-store-ui
- retail-store-catalog
- retail-store-cart
- retail-store-orders
- retail-store-checkout

#### **IAM Configuration**:
Create IAM user with ECR permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:CreateRepository",
        "ecr:DescribeRepositories"
      ],
      "Resource": "*"
    }
  ]
}
```

### **Step 3.2: GitHub Actions Workflows**

**Your Task**: Create GitHub Actions workflows for automated CI/CD.

#### **Required Workflow Files**:

1. **`.github/workflows/build.yml`**:
   - Trigger on push to main branch
   - Detect changed services in `src/` directory
   - Build Docker images only for changed services
   - Push images to ECR with commit hash tags
   - Parallel builds for multiple services

2. **`.github/workflows/test.yml`**:
   - Trigger on pull requests and pushes
   - Run unit tests for all services
   - Security vulnerability scanning
   - Code quality checks

3. **`.github/workflows/deploy.yml`**:
   - Trigger on successful build completion
   - Update Helm chart values with new image tags
   - Commit changes back to repository
   - Generate deployment commands

#### **GitHub Secrets Configuration**:
```
AWS_ACCESS_KEY_ID      # AWS access key
AWS_SECRET_ACCESS_KEY  # AWS secret key
AWS_REGION            # AWS region
AWS_ACCOUNT_ID        # AWS account ID
```


## **Phase 4: Application Deployment**

### **Step 4.1: Helm Charts**

**Your Task**: Create and configure Helm charts for all 5 microservices.

#### **Service Configuration Requirements**:

| Service | Port | Resources | Health Check |
|---------|------|-----------|--------------|
| **UI** | 8080 | 512Mi RAM, 250m CPU | `/health` |
| **Catalog** | 8080 | 256Mi RAM, 100m CPU | `/health` |
| **Cart** | 8080 | 512Mi RAM, 250m CPU | `/health` |
| **Orders** | 8080 | 512Mi RAM, 250m CPU | `/health` |
| **Checkout** | 8080 | 256Mi RAM, 100m CPU | `/health` |



### **Step 4.2: Manual Deployment**

**Your Task**: Deploy the application using Helm charts with manual commands.

#### **Deployment Order** (respect dependencies):

```bash
# 1. Deploy infrastructure services first
kubectl apply -f infrastructure/

# 2. Deploy Catalog Service (depends on PostgreSQL)
helm install catalog ./src/catalog/chart

# 3. Deploy Orders Service (depends on PostgreSQL)
helm install orders ./src/orders/chart

# 4. Deploy Cart Service (depends on Redis, DynamoDB)
helm install cart ./src/cart/chart

# 5. Deploy Checkout Service (depends on Cart, Orders, RabbitMQ)
helm install checkout ./src/checkout/chart

# 6. Deploy UI Service (depends on all other services)
helm install ui ./src/ui/chart
```

#### **Deployment Verification**:
```bash
# Check pod status
kubectl get pods

# Check service status
kubectl get svc

# Check ingress status
kubectl get ingress

# Test application access
curl http://your-load-balancer-ip
```

### **Step 4.3: Ingress Controller**

**Your Task**: Install and configure NGINX Ingress Controller for external access.

#### **Install Ingress Controller**:
```bash
# Add NGINX Ingress Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller
helm install ingress-nginx ingress-nginx/ingress-nginx

# Get external IP
kubectl get svc -n ingress-nginx
```

#### **Configure Ingress Resources**:
Create ingress configuration for external access to your application.


## 📚 Learning Resources

### **Kubernetes**
- [kubeadm Installation Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
- [Cluster Networking](https://kubernetes.io/docs/concepts/services-networking/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress/)

### **Terraform**
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EC2 Instance Management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

### **CI/CD and Deployment**
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Helm Documentation](https://helm.sh/docs/)
- [ECR User Guide](https://docs.aws.amazon.com/ecr/)


---

