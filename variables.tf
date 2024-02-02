####
# Global
####
variable "name_prefix" {
  type        = string
  description = "Name to prefix provisioned resources."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

####
# Bucket
####
variable "bucket_policy" {
  type        = string
  description = "The bucket policy to attah to the bucket"
}

variable "block_public_access" {
  type        = bool
  description = "Enable or disable public access for the bucket"
  default     = true
}

variable "bucket_acl_enabled" {
  type        = bool
  description = "Enable bucket ACLs"
  default     = false
}

variable "bucket_logging_enabled" {
  type        = bool
  description = "Enable bucket logging"
  default     = false
}

variable "bucket_logging_prefix" {
  type        = bool
  description = "Set the prefix for bucket logging objects"
  default     = "/log"
}

variable "bucket_versioning_enabled" {
  type        = bool
  description = "Enable bucket versioning"
  default     = true
}

variable "bucket_name" {
  type        = string
  description = "Set the name of the s3 bucket"
}

variable "control_object_ownership" {
  type        = bool
  description = "Enable object ownership controls"
  default     = false
}

variable "object_ownership" {
  type        = string
  description = "Object ownership"
  default     = "ObjectWriter"
}

variable "attach_access_log_delivery_policy" {
  description = "Controls if S3 bucket should have S3 access log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "object_lock_enabled" {
  description = "Whether S3 bucket should have an Object Lock configuration enabled."
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}
