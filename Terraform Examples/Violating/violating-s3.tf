# SECURITY VIOLATION EXAMPLE - S3 Public Bucket
# This file intentionally contains security violations for manual review practice

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ❌ VIOLATION: Public S3 bucket
resource "aws_s3_bucket" "company_data" {
  bucket = "company-sensitive-data-bucket"
  acl    = "public-read"  # ❌ CRITICAL: Allows public access
  
  # ❌ VIOLATION: Missing required tags
  tags = {
    Name = "data-bucket"
    # Missing: Environment, Owner, Project, CostCenter
  }
}

# ❌ VIOLATION: No encryption configuration
# ❌ VIOLATION: No public access block
# ❌ VIOLATION: No versioning enabled