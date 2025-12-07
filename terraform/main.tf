# Create ECR repositories for each service

resource "aws_ecr_repository" "service" {
  for_each = toset(var.services)

  name                 = "retail-store-${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project_name
    Service = each.key
  }
}

# New IAM policy for CI to push to ECR

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "ci_ecr_push" {
  name        = "${var.project_name}-ci-ecr-push"
  description = "Allow CI/CD to push images for retail-store services to ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowECRActions"
        Effect   = "Allow"
        Action   = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = [
          for repo in aws_ecr_repository.service :
          repo.arn
        ]
      },
      {
        Sid    = "AllowGlobalAuthToken"
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*"
      }
    ]
  })
}

# Cluster networking

resource "aws_vpc" "cluster" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

#resource "aws_internet_gateway" "igw" {
#  vpc_id = aws_vpc.cluster.id
#
#  tags = {
#    Name    = "${var.project_name}-igw"
#    Project = var.project_name
#  }
#}

#resource "aws_subnet" "public" {
#  vpc_id                  = aws_vpc.cluster.id
#  cidr_block              = var.public_subnet_cidr
#  map_public_ip_on_launch = true
#
#  tags = {
#    Name    = "${var.project_name}-public-subnet"
#    Project = var.project_name
#  }
#}

#resource "aws_route_table" "public" {
#  vpc_id = aws_vpc.cluster.id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.igw.id
#  }
#
#  tags = {
#    Name    = "${var.project_name}-public-rt"
#    Project = var.project_name
#  }
#}

#resource "aws_route_table_association" "public" {
#  subnet_id      = aws_subnet.public.id
#  route_table_id = aws_route_table.public.id
#}

#resource "aws_security_group" "cluster_nodes" {
#  name        = "${var.project_name}-nodes-sg"
#  description = "Security group for Kubernetes nodes"
#  vpc_id      = aws_vpc.cluster.id

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

#  ingress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = [aws_vpc.cluster.cidr_block]
#  }

#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name    = "${var.project_name}-nodes-sg"
#    Project = var.project_name
#  }
#}

# EC2 instances for kubeadm cluster

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

# Control-plane node
resource "aws_instance" "controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_controller
  #subnet_id              = aws_subnet.public.id
  associate_public_ip_address = true
  key_name               = var.ssh_key_name
  #security_groups        = [aws_security_group.cluster_nodes.id]

tags = {
    Name    = "${var.project_name}-controller"
    Project = var.project_name
    Role    = "controller"
  }

  lifecycle {
    ignore_changes = [
      ami,
      instance_type,
      subnet_id,
      vpc_security_group_ids,
      iam_instance_profile,
      user_data,
      tags,
    ]
  }


}

# Worker nodes
resource "aws_instance" "worker" {
  count                  = var.worker_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_worker
  #subnet_id              = aws_subnet.public.id
  associate_public_ip_address = true
  key_name               = var.ssh_key_name
  #security_groups        = [aws_security_group.cluster_nodes.id]

  tags = {
    Name    = "${var.project_name}-worker-${count.index}"
    Project = var.project_name
    Role    = "worker"
  }

lifecycle {
    ignore_changes = [
      ami,
      instance_type,
      subnet_id,
      vpc_security_group_ids,
      iam_instance_profile,
      user_data,
      tags,
    ]
  }
}
