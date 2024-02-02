resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  control_object_ownership = var.control_object_ownership
  object_ownership         = var.object_ownership
  object_lock_enabled      = var.object_lock_enabled

  tags = var.tags


}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.block_public_access ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket" "logging_bucket" {
  count = var.bucket_logging_enabled ? 1 : 0

  bucket = "${var.bucket_name}-logging"

  target_bucket = aws_s3_bucket.logging_bucket
  target_prefix = var.bucket_logging_prefix

  tags = var.tags


}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = var.bucket_policy ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode(var.bucket_policy)
}

resource "aws_s3_bucket_logging" "example" {
  count = var.bucket_logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}
