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

  bucket_name         = "sample-test-bucket-ekjhgfhkjedbfiewgncb"
  versioning          = "Enabled"
  logging_enabled     = true
  logging_bucket_name = "sample-logging-test-kumaryts"
  enable_lifecycle    = "true"
  lifecycle_rules = [
    {
      id              = "log"
      status          = "Enabled"
      prefix          = "/"
      expiration_days = 90
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 60, storage_class = "GLACIER" }
      ]
    }
  ]
}
