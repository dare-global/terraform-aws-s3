resource "aws_s3_bucket" "bucket" {
  bucket        = var.use_bucket_prefix ? null : var.bucket_name
  bucket_prefix = var.use_bucket_prefix ? var.bucket_prefix : null

  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_id : null
    }
    bucket_key_enabled = var.sse_algorithm == "aws:kms" ? (var.enable_bucket_key ? true : false) : false
  }
}

resource "aws_s3_bucket_versioning" "bucket" {
  count  = var.versioning == "Enabled" ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  count  = var.configure_policy ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  policy = var.bucket_policy
}

resource "aws_s3_bucket_logging" "bucket" {
  count         = var.logging_enabled ? 1 : 0
  bucket        = aws_s3_bucket.bucket.id
  target_bucket = var.logging_bucket_name
  target_prefix = "${aws_s3_bucket.bucket.id}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.expiration_days != null ? [rule.value.expiration_days] : []
        content {
          noncurrent_days = rule.value.expiration_days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.transitions != null ? rule.value.transitions : []
        content {
          noncurrent_days = transition.value.days
          storage_class   = transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = var.index_document
  }

  dynamic "error_document" {
    for_each = var.error_document != null ? [var.error_document] : []
    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.redirect_all_requests_to != null ? [var.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }

  dynamic "routing_rules" {
    for_each = length(var.routing_rules) > 0 ? var.routing_rules : []
    content {
      condition {
        http_error_code_returned_equals = routing_rules.value.condition.http_error_code_returned_equals
        key_prefix_equals               = routing_rules.value.condition.key_prefix_equals
      }

      redirect {
        host_name               = routing_rules.value.redirect.host_name
        http_redirect_code      = routing_rules.value.redirect.http_redirect_code
        protocol                = routing_rules.value.redirect.protocol
        replace_key_prefix_with = routing_rules.value.redirect.replace_key_prefix_with
      }
    }
  }
}

