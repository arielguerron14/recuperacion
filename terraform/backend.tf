# ============================================================================
# TERRAFORM BACKEND CONFIGURATION (OPTIONAL)
# ============================================================================
# Uncomment and configure if you want to store state remotely (e.g., S3)
# ============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "recuperacion/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

# ============================================================================
# LOCAL BACKEND (DEFAULT)
# ============================================================================
# By default, Terraform stores state locally in terraform.tfstate
# This file is automatically created when you run 'terraform init'
