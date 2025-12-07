variable "aws_region" {
  description = "AWS region to deploy ECR and other infra into"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name prefix for tagging"
  type        = string
  default     = "retail-store-sample-app"
}

variable "services" {
  description = "List of microservices that get their own ECR repos"
  type        = list(string)
  default     = ["ui", "catalog", "cart", "orders", "checkout"]
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type_controller" {
  description = "EC2 instance type for control-plane node"
  type        = string
  default     = "t3.large"
}

variable "instance_type_worker" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.large"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "ssh_key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
}
