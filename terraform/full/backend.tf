# Optional backend configuration. Keep commented unless you configure S3/DynamoDB for state locking.

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "recuperacion/full/terraform.tfstate"
#     region         = var.region
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

# Default local backend will be used if nothing is configured.
