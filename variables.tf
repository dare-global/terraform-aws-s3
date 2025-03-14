variable "bucket_name" {
  type        = string
  description = "Name of the s3 bucket"
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
  description = "lifecycle rule for objects"
  default     = []
}
