resource "aws_s3_bucket" "main" {
  count         = var.create_bucket ? 1 : 0
  bucket        = var.use_bucket_prefix ? null : var.bucket_name
  bucket_prefix = var.use_bucket_prefix ? var.bucket_prefix : null

  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_bucket_ownership_controls" "main" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "main" {
  count      = var.object_ownership != "BucketOwnerEnforced" && var.enable_acl && var.create_bucket ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.main]
  bucket     = aws_s3_bucket.main[count.index].id

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
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_id : null
    }
    bucket_key_enabled = var.sse_algorithm == "aws:kms" ? (var.enable_bucket_key ? true : false) : false
  }
}

resource "aws_s3_bucket_versioning" "main" {
  count  = var.versioning == "Enabled" && var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id

  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_policy" "main" {
  count  = var.configure_policy && var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id
  policy = var.bucket_policy
  lifecycle {
    precondition {
      condition     = var.bucket_policy != null
      error_message = "When 'configure_policy' is true then 'bucket_policy' attribute is required."
    }
  }
}

resource "aws_s3_bucket_logging" "main" {
  count         = var.logging_enabled && var.create_bucket ? 1 : 0
  bucket        = aws_s3_bucket.main[count.index].id
  target_bucket = var.logging_bucket_name
  target_prefix = "${aws_s3_bucket.main[count.index].id}/"
  lifecycle {
    precondition {
      condition     = var.logging_bucket_name != null
      error_message = "When 'logging_enabled' is true then 'logging_bucket_name' attribute is required."
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = length(var.lifecycle_rules) > 0 && var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id

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
  count  = var.enable_website_configuration && var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id

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
  count  = length(var.cors_rules) > 0 && var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id

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
  count  = var.enable_s3_notification && var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.main[count.index].id

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

resource "aws_s3_bucket_replication_configuration" "main" {
  count = var.replication_configuration != null ? 1 : 0

  depends_on = [aws_s3_bucket_versioning.main]

  bucket = aws_s3_bucket.main[count.index].id
  role   = var.replication_configuration.role

  dynamic "rule" {
    for_each = var.replication_configuration.rule
    content {
      id       = try(rule.value.id, null)
      status   = rule.value.status
      priority = try(rule.value.priority, null)

      dynamic "delete_marker_replication" {
        for_each = try(rule.value.delete_marker_replication, null) != null ? [rule.value.delete_marker_replication] : []

        content {
          status = delete_marker_replication.value.status
        }
      }

      dynamic "source_selection_criteria" {
        for_each = try(rule.value.source_selection_criteria, null) != null ? [rule.value.source_selection_criteria] : []

        content {
          dynamic "replica_modifications" {
            for_each = try(source_selection_criteria.value.replica_modifications, null) != null ? [source_selection_criteria.value.replica_modifications] : []
            content {
              status = replica_modifications.value.status
            }
          }
          dynamic "sse_kms_encrypted_objects" {
            for_each = try(source_selection_criteria.value.sse_kms_encrypted_objects, null) != null ? [source_selection_criteria.value.sse_kms_encrypted_objects] : []
            content {
              status = sse_kms_encrypted_objects.value.status
            }
          }
        }
      }

      # empty filter
      dynamic "filter" {
        for_each = rule.value.filter == null ? [true] : []
        content {}
      }

      # 1 filter
      dynamic "filter" {
        for_each = rule.value.filter != null && try(rule.value.filter.tags, null) == null ? [rule.value.filter] : []
        content {
          prefix = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = filter.value.tag != null ? [filter.value.tag] : []
            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
        }
      }

      dynamic "filter" {
        for_each = rule.value.filter != null && try(rule.value.filter.tags, null) != null ? [rule.value.filter] : []
        content {
          and {
            prefix = try(filter.value.prefix, null)
            tags   = try(filter.value.tags, null)
          }
        }
      }

      dynamic "destination" {
        for_each = try([rule.value.destination], [])
        content {
          bucket        = destination.value.bucket
          storage_class = try(destination.value.storage_class, null)
          account       = try(destination.value.account, null)

          dynamic "access_control_translation" {
            for_each = try(destination.value.access_control_translation, null) != null ? [destination.value.access_control_translation] : []

            content {
              owner = access_control_translation.value.owner
            }
          }

          dynamic "encryption_configuration" {
            for_each = try(destination.value.encryption_configuration, null) != null ? [destination.value.encryption_configuration] : []

            content {
              replica_kms_key_id = encryption_configuration.value.replica_kms_key_id
            }
          }

          dynamic "replication_time" {
            for_each = try(destination.value.replication_time, null) != null ? [destination.value.replication_time] : []

            content {
              status = replication_time.value.status
              time {
                minutes = replication_time.value.time.minutes
              }
            }
          }

          dynamic "metrics" {
            for_each = try(destination.value.metrics, null) != null ? [destination.value.metrics] : []

            content {
              status = metrics.value.status

              dynamic "event_threshold" {
                for_each = try(metrics.value.event_threshold, null) != null ? [metrics.value.event_threshold] : []

                content {
                  minutes = event_threshold.value.minutes
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_s3_access_point" "main" {
  for_each = var.enable_access_points ? { for access_point in var.access_points : access_point.name => access_point } : {}

  bucket = var.bucket_name
  name   = each.key

  public_access_block_configuration {
    block_public_acls       = each.value.block_public_acls
    block_public_policy     = each.value.block_public_policy
    ignore_public_acls      = each.value.ignore_public_acls
    restrict_public_buckets = each.value.restrict_public_buckets
  }

  dynamic "vpc_configuration" {
    for_each = try(each.value.vpc_id, null) != null ? [1] : []
    content {
      vpc_id = each.value.vpc_id
    }
  }
  policy = try(each.value.policy, null)

  lifecycle {
    precondition {
      condition     = each.key != null && each.key != ""
      error_message = "Access point name cannot be empty."
    }
  }
}

resource "aws_s3_directory_bucket" "main" {
  count           = var.create_directory_bucket ? 1 : 0
  bucket          = var.directory_bucket_name
  data_redundancy = var.data_redundancy
  force_destroy   = var.force_destroy

  location {
    name = var.location_name
    type = var.location_type
  }

  lifecycle {
    precondition {
      condition     = can(regex("^[a-zA-Z0-9.-]+--[a-z0-9.-]+--x-s3$", var.directory_bucket_name))
      error_message = "The bucket name must be in the format [bucket_name]--[azid]--x-s3."
    }

    precondition {
      condition     = contains(["SingleAvailabilityZone", "SingleLocalZone"], var.data_redundancy)
      error_message = "Invalid value for data_redundancy. Allowed values: SingleAvailabilityZone, SingleLocalZone."
    }

    precondition {
      condition     = contains(["AvailabilityZone", "LocalZone"], var.location_type)
      error_message = "Invalid location type. Allowed values: AvailabilityZone, LocalZone."
    }
  }
}
