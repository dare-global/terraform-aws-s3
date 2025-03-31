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

  bucket_name      = "example"
  versioning       = "Enabled"
  object_ownership = "BucketOwnerEnforced"

  replication_configuration = {
    role = ""
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
          tag    = { key = "yN", value = "Yes" }
        }

        destination = {
          bucket        = ""
          storage_class = "STANDARD"

          encryption_configuration = {
            replica_kms_key_id = ""
          }
          account = "000000000000"

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
          bucket        = ""
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
          bucket        = ""
          storage_class = "STANDARD"
        }
      },
      {
        id     = "everything-without-filters"
        status = "Disabled"

        destination = {
          bucket        = ""
          storage_class = "STANDARD"
        }
      },
    ]
  }
}
