terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.90.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = "sample-test-bucket"
  cors_rules = [
    {
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["http://example.com"]
      allowed_headers = ["Access-Control-Request-Headers"]
    }
  ]
}
