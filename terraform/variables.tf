variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2/2023 (AWS Academy: get from EC2 > AMIs)"
  type        = string
  default     = "ami-068c0051b15cdb816"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be launched (AWS Academy: existing subnets)"
  type        = list(string)
  default = [
    "subnet-04072a323ee81077c",
    "subnet-073421f75a8a9152f",
    "subnet-0d50fdef169672ed8",
    "subnet-0b53b46775431cbec",
    "subnet-0866ecd5b9dfb497d",
    "subnet-0972d21dde8f67c68"
  ]
}

variable "ec2_sg_id" {
  description = "Security Group ID for EC2 instances (AWS Academy: existing SG)"
  type        = string
  default     = "sg-000487d4bbef1ba0b"
}

variable "tg_arn" {
  description = "Target Group ARN for ALB (AWS Academy: existing ALB target group)"
  type        = string
  default     = "arn:aws:elasticloadbalancing:us-east-1:533267090491:targetgroup/hola-tg/ed19b35e8d07a549"
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

variable "repo_url" {
  description = "Public GitHub repository URL containing the Docker app"
  type        = string
  default     = "https://github.com/arielguerron14/recuperacion.git"
}
