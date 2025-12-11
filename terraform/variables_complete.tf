# ============================================================================
# TERRAFORM VARIABLES FOR AWS INFRASTRUCTURE
# ============================================================================
# This file defines all input variables for the infrastructure deployment
# ============================================================================

# ============================================================================
# GENERAL CONFIGURATION
# ============================================================================

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name (used for naming resources)"
  type        = string
  default     = "hola-mundo"
}

# ============================================================================
# VPC AND NETWORKING
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# ============================================================================
# EC2 CONFIGURATION
# ============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# ============================================================================
# AUTO SCALING GROUP CONFIGURATION
# ============================================================================

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

# ============================================================================
# DOCKER AND APPLICATION CONFIGURATION
# ============================================================================

variable "container_port" {
  description = "Port where the Docker container listens (exposed from host port 80)"
  type        = number
  default     = 3000
}

variable "github_repo_url" {
  description = "GitHub repository URL containing the Docker application"
  type        = string
  default     = "https://github.com/arielguerron14/recuperacion.git"
}

# ============================================================================
# TAGS
# ============================================================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Terraform   = "true"
    Project     = "hola-mundo-docker"
  }
}
