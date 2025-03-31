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
  region = "us-east-1"
}

module "s3_bucket" {
  source = "../../"

  create_bucket           = false
  create_directory_bucket = true
  directory_bucket_name   = "sample-test-bucket--use1-az4--x-s3"
  location_name           = "use1-az4"
}
