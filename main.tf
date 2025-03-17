resource "aws_s3_bucket" "main" {
  bucket        = var.use_bucket_prefix ? null : var.bucket_name
  bucket_prefix = var.use_bucket_prefix ? var.bucket_prefix : null

  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_id : null
    }
    bucket_key_enabled = var.sse_algorithm == "aws:kms" ? (var.enable_bucket_key ? true : false) : false
  }
}

resource "aws_s3_bucket_versioning" "main" {
  count  = var.versioning == "Enabled" ? 1 : 0
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_policy" "main" {
  count  = var.configure_policy ? 1 : 0
  bucket = aws_s3_bucket.main.id
  policy = var.bucket_policy
  lifecycle {
    precondition {
      condition     = !var.configure_policy || var.bucket_policy != null
      error_message = "When 'configure_policy' is true then 'bucket_policy' attribute is required."
    }
  }
}

resource "aws_s3_bucket_logging" "main" {
  count         = var.logging_enabled ? 1 : 0
  bucket        = aws_s3_bucket.main.id
  target_bucket = var.logging_bucket_name
  target_prefix = "${aws_s3_bucket.main.id}/"
  lifecycle {
    precondition {
      condition     = !var.logging_enabled || var.logging_bucket_name != null
      error_message = "When 'logging_enabled' is true then 'logging_bucket_name' attribute is required."
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.main.id

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
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
  lifecycle {
    precondition {
      condition     = !var.enable_lifecycle || length(var.lifecycle_rules) > 0
      error_message = "When 'enable_lifecycle' is true then 'lifecycle_rules' attribute is required."
    }
  }
}

resource "aws_s3_bucket_website_configuration" "main" {
  count  = var.enable_website_configuration ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "error_document" {
    for_each = var.error_document != null && var.redirect_all_requests_to == null ? [var.error_document] : []
    content {
      key = error_document.value
    }
  }

  dynamic "index_document" {
    for_each = var.index_document != null && var.redirect_all_requests_to == null ? [var.index_document] : []
    content {
      suffix = index_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.redirect_all_requests_to != null && var.index_document == null ? [var.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }

  dynamic "routing_rule" {
    for_each = length(var.routing_rule) > 0 && var.redirect_all_requests_to == null ? var.routing_rule : []
    content {
      condition {
        http_error_code_returned_equals = lookup(routing_rule.value.condition, "http_error_code_returned_equals", null)
        key_prefix_equals               = lookup(routing_rule.value.condition, "key_prefix_equals", null)
      }

      redirect {
        host_name               = lookup(routing_rule.value.redirect, "host_name", null)
        http_redirect_code      = lookup(routing_rule.value.redirect, "http_redirect_code", null)
        protocol                = lookup(routing_rule.value.redirect, "protocol", null)
        replace_key_prefix_with = lookup(routing_rule.value.redirect, "replace_key_prefix_with", null)
        replace_key_with        = lookup(routing_rule.value.redirect, "replace_key_with", null)
      }
    }
  }
  lifecycle {
    precondition {
      condition = !var.enable_website_configuration || (
        (
          (var.index_document != null && var.redirect_all_requests_to == null) ||
          (var.index_document == null && var.redirect_all_requests_to != null)
        ) &&
        (
          (length(var.routing_rule) == 0 || var.redirect_all_requests_to == null) &&
          (var.error_document == null || var.redirect_all_requests_to == null)
        ) ||
        (var.error_document != null && length(var.routing_rule) > 0 && var.redirect_all_requests_to == null)
      )
      error_message = "When 'enable_website_configuration' is true, either 'index_document' or 'redirect_all_requests_to' must be provided, but not both. 'error_document' and 'index_document' be used with 'routing_rules' when 'redirect_all_requests_to' is not specified."
    }
  }
}

