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

resource "aws_s3_bucket_acl" "main" {
  count      = var.object_ownership != "BucketOwnerEnforced" && var.enable_acl == true ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.main]
  bucket     = aws_s3_bucket.main.id

  dynamic "access_control_policy" {
    for_each = var.access_control_policy != null ? [var.access_control_policy] : []
    content {
      owner {
        id           = access_control_policy.value.owner.id
        display_name = try(access_control_policy.value.owner.display_name, null)
      }

      dynamic "grant" {
        for_each = access_control_policy.value.grant
        content {
          grantee {
            type          = grant.value.grantee.type
            email_address = try(grant.value.grantee.email_address, null)
            id            = try(grant.value.grantee.id, null)
            uri           = try(grant.value.grantee.uri, null)
          }
          permission = grant.value.permission
        }
      }
    }
  }

  acl = var.access_control_policy == null ? var.acl : null

  lifecycle {
    precondition {
      condition     = !(var.acl != null && var.access_control_policy != null)
      error_message = "Only one of acl or access_control_policy should be provided, not both."
    }
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
      condition     = var.bucket_policy != null
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
      condition     = var.logging_bucket_name != null
      error_message = "When 'logging_enabled' is true then 'logging_bucket_name' attribute is required."
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
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
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          noncurrent_days           = noncurrent_version_expiration.value.days
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.transitions != null ? rule.value.transitions : []
        content {
          noncurrent_days           = noncurrent_version_transition.value.days
          storage_class             = noncurrent_version_transition.value.storage_class
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
        }
      }
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
    for_each = length(var.routing_rule) > 0 && var.redirect_all_requests_to == null && var.routing_rules == null ? var.routing_rule : []
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

  routing_rules = length(var.routing_rules) > 0 && var.redirect_all_requests_to == null && var.routing_rule == null ? var.routing_rules : ""

}

resource "aws_s3_bucket_cors_configuration" "main" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = var.bucket_name

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
      id              = try(cors_rule.value.id, null)
    }
  }
}

resource "aws_s3_bucket_notification" "main" {
  count  = var.enable_s3_notification ? 1 : 0
  bucket = var.bucket_name

  eventbridge = var.eventbridge

  dynamic "lambda_function" {
    for_each = var.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
      id                  = lookup(lambda_function.value, "id", null)
    }
  }

  dynamic "queue" {
    for_each = var.sqs_notifications
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
      id            = lookup(queue.value, "id", null)
    }
  }

  dynamic "topic" {
    for_each = var.sns_notifications
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
      id            = lookup(topic.value, "id", null)
    }
  }
}
