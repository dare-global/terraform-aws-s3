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

  bucket_name            = "sample-test-bucket"
  enable_s3_notification = true
  sqs_notifications = [
    {
      events    = ["s3:ObjectCreated:*"]
      queue_arn = "arn:aws:sqs:eu-west-2:1234567890:test-queue"
    }
  ]
}
