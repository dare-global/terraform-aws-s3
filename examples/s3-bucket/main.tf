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

  bucket_name         = "sample-test-bucket"
  versioning          = "Enabled"
  logging_enabled     = true
  logging_bucket_name = "sample-logging-bucket"
  object_ownership    = "BucketOwnerEnforced"
  lifecycle_rules = [
    {
      id     = "log"
      status = "Enabled"
      filter = {
        prefix = ""
      }
      expiration = {
        days = 90
      }
      transition = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }]
      noncurrent_version_expiration = {
        noncurrent_days           = 60
        newer_noncurrent_versions = 30
      }
      noncurrent_version_transition = [
        { noncurrent_days = 30, storage_class = "STANDARD_IA" },
      ]
    }
  ]
}
