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

  bucket_name                  = "sample-test-bucket-ekjhgfhkjedbfiewgncb"
  enable_website_configuration = true
  index_document               = "index.html"
  error_document               = "error.html"
  routing_rule = [
    {
      condition = {
        http_error_code_returned_equals = "404"
      }
      redirect = {
        host_name               = "www.example.com"
        http_redirect_code      = "301"
        protocol                = "https"
        replace_key_prefix_with = "error/"
      }
    }
  ]
}
