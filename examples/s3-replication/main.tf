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
  source = "../.."

  bucket_name      = "sacdvsdcmp2"
  versioning       = "Enabled"
  object_ownership = "BucketOwnerEnforced"

  replication_configuration = {
    role = "arn:aws:iam::096445827817:role/s3-replication"
    rule = [
      {
        id       = "something-with-kms-and-filter"
        status   = "Enabled"
        priority = 10

        delete_marker_replication = {
          status = "Disabled"
        }

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }
          sse_kms_encrypted_objects = {
            status = "Enabled"
          }
        }

        filter = {
          prefix = "one"
          tag    = { key = "yo", value = "Yes" }
        }

        destination = {
          bucket        = "arn:aws:s3:::asset-12042023-dev"
          storage_class = "STANDARD"

          encryption_configuration = {
            replica_kms_key_id = "arn:aws:kms:eu-west-2:096445827817:key/71340f16-a1cb-4492-96c5-ade535a40d4f"
          }
          account = "096445827817"

          access_control_translation = {
            owner = "Destination"
          }

          replication_time = {
            status = "Enabled"
            time = {
              minutes = 15
            }
          }

          metrics = {
            status = "Enabled"
            event_threshold = {
              minutes = 15
            }
          }
        }
      },
      {
        id       = "something-with-filter"
        priority = 20
        status   = "Enabled"

        delete_marker_replication = {
          status = "Disabled"
        }

        filter = {
          prefix = "two"
          tags   = { "ReplicateMe" = "Yes", "ReplicateMe1" = "Yes11" }
        }

        destination = {
          bucket        = "arn:aws:s3:::asset-12042023-dev"
          storage_class = "STANDARD"
        }
      },
      {
        id       = "everything-with-filter"
        status   = "Enabled"
        priority = 30

        delete_marker_replication = {
          status = "Disabled"
        }

        filter = {
          prefix = ""
        }

        destination = {
          bucket        = "arn:aws:s3:::asset-12042023-dev"
          storage_class = "STANDARD"
        }
      },
      {
        id     = "everything-without-filters"
        status = "Disabled"

        destination = {
          bucket        = "arn:aws:s3:::asset-12042023-dev"
          storage_class = "STANDARD"
        }
      },
    ]
  }
}
