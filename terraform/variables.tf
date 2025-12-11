variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "ASG minimum size"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "ASG maximum size"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "VPC ID (AWS Academy: get from VPC console)"
  type        = string
  default     = "vpc-034876c26c081f71e"
}

variable "subnet_ids" {
  description = "List of subnet IDs (AWS Academy: get from Subnets console)"
  type        = list(string)
  default     = [
    "subnet-04072a323ee81077c",
    "subnet-073421f75a8a9152f",
    "subnet-0d50fdef169672ed8",
    "subnet-0b53b46775431cbec",
    "subnet-0866ecd5b9dfb497d",
    "subnet-0972d21dde8f67c68"
  ]
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2 (AWS Academy: get from EC2 > AMIs console)"
  type        = string
  default     = "ami-068c0051b15cdb816"
}

variable "repo_url" {
  description = "Public GitHub repository URL containing the app (https)"
  type        = string
  default     = "https://github.com/your-username/proyecto-hola-mundo.git"
}
