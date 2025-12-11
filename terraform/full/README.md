# Full Terraform deployment (terraform/full)

This folder contains the complete infrastructure Terraform configuration:
- VPC + public subnets
- Internet Gateway + Route Tables
- Security Groups for ALB and EC2
- Application Load Balancer + Target Group + Listener
- Launch Template + Auto Scaling Group
- User data script to install Docker and deploy from GitHub

Usage:

```bash
cd terraform/full
cp terraform.tfvars.example terraform.tfvars    # edit values if needed
terraform init
terraform plan
terraform apply
```

Notes:
- Run Terraform commands inside `terraform/full` to avoid conflicts with other .tf files in the repo.
- To use remote state, configure the `backend.tf` file (S3 + DynamoDB recommended).
- The user data script maps container port to host port 80.
