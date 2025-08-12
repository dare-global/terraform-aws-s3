terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "s3_bucket" {
  source = "../../"

  bucket_name          = "sample-test-bucket"
  enable_access_points = true
  access_points = [
    {
      name = "sample-test"
      tags = {
        "test" = "abc"
      }
      block_public_acls       = false
      block_public_policy     = true
      ignore_public_acls      = false
      restrict_public_buckets = true
      policy = jsonencode({
        Id = "testAccessPointPolicy"
        Statement = [
          {
            Action = "s3:ListBucket"
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Resource = "arn:aws:s3:eu-west-2:1234567890:accesspoint/sample-test"
            Sid      = "statement1"
          }
        ]
        Version = "2012-10-17"
      })
    }
  ]
}
