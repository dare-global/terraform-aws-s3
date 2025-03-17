variable "use_bucket_prefix" {
  type        = bool
  description = "whether to use bucket prefix for the s3 bucket name"
  default     = false
}

variable "bucket_name" {
  type        = string
  description = "Name of the s3 bucket"
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

variable "enable_lifecycle" {
  type        = bool
  description = "Whether to define s3 lifecycle rule"
  default     = false
}

variable "lifecycle_rules" {
  type = list(object({
    id              = string
    status          = string
    prefix          = string
    expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  description = "lifecycle rule for objects transition to different storage classes"
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

