variable "create_bucket" {
  type        = bool
  description = "whether to create S3 bucket"
  default     = true
}

variable "use_bucket_prefix" {
  type        = bool
  description = "whether to use bucket prefix for the s3 bucket name"
  default     = false
}

variable "bucket_name" {
  type        = string
  description = "Name of the s3 bucket"
  default     = null
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix name of the s3 bucket"
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = "Deletes all objects and bucket"
  default     = false
}

variable "object_lock_enabled" {
  type        = bool
  description = "Enable object locking in bucket"
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "object_ownership" {
  type        = string
  description = "Object ownership for bucket"
  default     = "BucketOwnerEnforced"
}

variable "enable_acl" {
  type        = bool
  description = "Whether to enable ACL for bucket"
  default     = false
}

variable "acl" {
  type        = string
  description = "Canned config to apply to the bucket"
  default     = null
}

variable "access_control_policy" {
  type = object({
    owner = object({
      id           = string
      display_name = optional(string)
    })
    grant = list(object({
      grantee = object({
        type          = string
        email_address = optional(string)
        id            = optional(string)
        uri           = optional(string)
      })
      permission = string
    }))
  })
  description = "Access control policy configuration for the bucket"
  default     = null
}

variable "block_public_acls" {
  type        = bool
  description = "block public acls for bucket"
  default     = "true"
}

variable "block_public_policy" {
  type        = bool
  description = "block public policy for bucket"
  default     = "true"
}

variable "ignore_public_acls" {
  type        = bool
  description = "ignore public acls for bucket"
  default     = "true"
}

variable "restrict_public_buckets" {
  type        = bool
  description = "restrict public bucket"
  default     = "true"
}

variable "sse_algorithm" {
  type        = string
  description = "server side encryption algorithm for bucket"
  default     = "AES256"
}

variable "enable_bucket_key" {
  type        = bool
  description = "Enable bucket key"
  default     = false
}

variable "kms_key_id" {
  type        = string
  description = "KMS key arn to encrypt s3 bucket if sse algorith is aws:kms"
  default     = null
}

variable "versioning" {
  type        = string
  description = "Enable versioning for bucket"
  default     = null
}

variable "configure_policy" {
  type        = bool
  description = "Whether to define S3 bucket policy"
  default     = false
}

variable "bucket_policy" {
  type        = string
  description = "S3 bucket policy"
  default     = null
}

variable "logging_enabled" {
  type        = bool
  description = "Enable logging"
  default     = false
}

variable "logging_bucket_name" {
  type        = string
  description = "Destination bucket name to store S3 access logs"
  default     = null
}

variable "lifecycle_rules" {
  type = list(object({
    id     = string
    status = string
    prefix = string
    expiration = optional(object({
      days                      = number
      newer_noncurrent_versions = optional(number)
    }))
    transitions = optional(list(object({
      days                      = number
      storage_class             = string
      newer_noncurrent_versions = optional(number)
    })))
  }))
  description = "lifecycle rules for objects transition to different storage classes"
  default     = []
}

variable "enable_website_configuration" {
  type        = bool
  description = "Whether to enable website configuration for the bucket"
  default     = false
}

variable "index_document" {
  type        = string
  description = "The name of the index document for the website"
  default     = null
}

variable "error_document" {
  description = "The name of the error document for the website"
  type        = string
  default     = null
}

variable "redirect_all_requests_to" {
  description = "Redirect all requests to another website"
  type = object({
    host_name = string
    protocol  = optional(string)
  })
  default = null
}

variable "routing_rule" {
  type = list(object({
    condition = object({
      http_error_code_returned_equals = optional(string)
      key_prefix_equals               = optional(string)
    })
    redirect = object({
      host_name               = optional(string)
      http_redirect_code      = optional(string)
      protocol                = optional(string)
      replace_key_prefix_with = optional(string)
      replace_key_with        = optional(string)
    })
  }))
  description = "Routing rule configuration for website"
  default     = []
}

variable "routing_rules" {
  type        = string
  description = "Routing rules configuration for website"
  default     = ""
}

variable "cors_rules" {
  description = "List of CORS rules for the S3 bucket"
  type = list(object({
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string), [])
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number)
    id              = optional(string)
  }))
  default = []
}

variable "enable_s3_notification" {
  description = "Whether to enable S3 bucket notification"
  type        = bool
  default     = false
}

variable "eventbridge" {
  description = "Enable EventBridge notifications"
  type        = bool
  default     = false
}

variable "lambda_notifications" {
  description = "List of Lambda function notifications"
  type = list(object({
    lambda_function_arn = string
    events              = list(string)
    filter_prefix       = optional(string)
    filter_suffix       = optional(string)
    id                  = optional(string)
  }))
  default = []
}

variable "sqs_notifications" {
  description = "List of SQS queue notifications"
  type = list(object({
    queue_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
    id            = optional(string)
  }))
  default = []
}

variable "sns_notifications" {
  description = "List of SNS topic notifications"
  type = list(object({
    topic_arn     = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
    id            = optional(string)
  }))
  default = []
}


variable "enable_replication_configuration" {
  description = "Flag to Enable Replication Configuration"
  type        = bool
  default     = false
}

variable "replication_configuration" {
  description = "Enable Replication Configuration"
  type = object({
    role  = string
    token = optional(string)
    rule = list(object({
      id       = string
      status   = string
      priority = optional(number)
      filter = optional(object({
        tag = optional(object({
          key   = string
          value = string
        }))
        tags   = optional(map(any))
        prefix = optional(string)
      }))
      delete_marker_replication = optional(object({
        status = string
      }))
      destination = object({
        access_control_translation = optional(object({
          owner = string
        }))
        account = optional(string)
        bucket  = string
        encryption_configuration = optional(object({
          replica_kms_key_id = string
        }))
        metrics = optional(object({
          status = string
          event_threshold = optional(object({
            minutes = number
          }))
        }))
        replication_time = optional(object({
          status = string
          time = object({
            minutes = number
          })
        }))
        storage_class = optional(string)
      })
      source_selection_criteria = optional(object({
        replica_modifications = optional(object({
          status = string
        }))
        sse_kms_encrypted_objects = optional(object({
          status = string
        }))
      }))
    }))
  })
  default = null
}

variable "enable_access_points" {
  description = "Whether to enable access point for s3"
  type        = bool
  default     = false
}

variable "access_points" {
  description = "List of S3 access points"
  type = list(object({
    name                    = string
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
    vpc_id                  = optional(string, null)
    policy                  = optional(string, null)
  }))
  default = []
}

variable "create_directory_bucket" {
  description = "Whether to create S3 directory bucket"
  type        = bool
  default     = false
}

variable "directory_bucket_name" {
  description = "Name for directory bucket"
  type        = string
  default     = null
}

variable "data_redundancy" {
  description = "Type for data redundancy"
  type        = string
  default     = "SingleAvailabilityZone"
}

variable "location_name" {
  description = "Name of the Availability Zone ID or Local Zone ID"
  type        = string
  default     = null
}

variable "location_type" {
  description = "Location type for S3 directory bucket"
  type        = string
  default     = "AvailabilityZone"
}
