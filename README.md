# terraform-aws-s3
Terraform module for provisioning a S3 bucket

## Usage

```hcl
module "s3_bucket" {
  source  = "dare-global/s3/aws"
  version = "1.X.X"

  bucket_name = "my-bucket"
}
```

## Examples

* [s3-bucket](https://github.com/dare-global/terraform-aws-s3/tree/main/examples/s3-bucket/)
* [s3-website](https://github.com/dare-global/terraform-aws-s3/tree/main/examples/s3-website/)
* [s3-cors](https://github.com/dare-global/terraform-aws-s3/tree/main/examples/s3-cors/)
* [s3-notification](https://github.com/dare-global/terraform-aws-s3/tree/main/examples/s3-notification/)
* [s3-access-point](https://github.com/dare-global/terraform-aws-s3/tree/main/examples/s3-access-point/)
* [s3-directory-bucket](https://github.com/dare-global/terraform-aws-s3/tree/main/examples/s3-directory-bucket/)
* [s3-replication](https://github.com/dare-global/terraform-aws-s3/tree/main/examples/s3-replication/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.90.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.90.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_access_point.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_access_point) | resource |
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_ownership_controls.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_directory_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_directory_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_control_policy"></a> [access\_control\_policy](#input\_access\_control\_policy) | Access control policy configuration for the bucket | <pre>object({<br/>    owner = object({<br/>      id           = string<br/>      display_name = optional(string)<br/>    })<br/>    grant = list(object({<br/>      grantee = object({<br/>        type          = string<br/>        email_address = optional(string)<br/>        id            = optional(string)<br/>        uri           = optional(string)<br/>      })<br/>      permission = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_access_points"></a> [access\_points](#input\_access\_points) | List of S3 access points | <pre>list(object({<br/>    name                    = string<br/>    block_public_acls       = optional(bool, true)<br/>    block_public_policy     = optional(bool, true)<br/>    ignore_public_acls      = optional(bool, true)<br/>    restrict_public_buckets = optional(bool, true)<br/>    vpc_id                  = optional(string, null)<br/>    policy                  = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | Canned config to apply to the bucket | `string` | `null` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | block public acls for bucket | `bool` | `"true"` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | block public policy for bucket | `bool` | `"true"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the s3 bucket | `string` | `null` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | S3 bucket policy | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Prefix name of the s3 bucket | `string` | `null` | no |
| <a name="input_configure_policy"></a> [configure\_policy](#input\_configure\_policy) | Whether to define S3 bucket policy | `bool` | `false` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | List of CORS rules for the S3 bucket | <pre>list(object({<br/>    allowed_methods = list(string)<br/>    allowed_origins = list(string)<br/>    allowed_headers = optional(list(string), [])<br/>    expose_headers  = optional(list(string), [])<br/>    max_age_seconds = optional(number)<br/>    id              = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | whether to create S3 bucket | `bool` | `true` | no |
| <a name="input_create_directory_bucket"></a> [create\_directory\_bucket](#input\_create\_directory\_bucket) | Whether to create S3 directory bucket | `bool` | `false` | no |
| <a name="input_data_redundancy"></a> [data\_redundancy](#input\_data\_redundancy) | Type for data redundancy | `string` | `"SingleAvailabilityZone"` | no |
| <a name="input_directory_bucket_name"></a> [directory\_bucket\_name](#input\_directory\_bucket\_name) | Name for directory bucket | `string` | `null` | no |
| <a name="input_enable_access_points"></a> [enable\_access\_points](#input\_enable\_access\_points) | Whether to enable access point for s3 | `bool` | `false` | no |
| <a name="input_enable_acl"></a> [enable\_acl](#input\_enable\_acl) | Whether to enable ACL for bucket | `bool` | `false` | no |
| <a name="input_enable_bucket_key"></a> [enable\_bucket\_key](#input\_enable\_bucket\_key) | Enable bucket key | `bool` | `false` | no |
| <a name="input_enable_replication_configuration"></a> [enable\_replication\_configuration](#input\_enable\_replication\_configuration) | Flag to Enable Replication Configuration | `bool` | `false` | no |
| <a name="input_enable_s3_notification"></a> [enable\_s3\_notification](#input\_enable\_s3\_notification) | Whether to enable S3 bucket notification | `bool` | `false` | no |
| <a name="input_enable_website_configuration"></a> [enable\_website\_configuration](#input\_enable\_website\_configuration) | Whether to enable website configuration for the bucket | `bool` | `false` | no |
| <a name="input_error_document"></a> [error\_document](#input\_error\_document) | The name of the error document for the website | `string` | `null` | no |
| <a name="input_eventbridge"></a> [eventbridge](#input\_eventbridge) | Enable EventBridge notifications | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Deletes all objects and bucket | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | ignore public acls for bucket | `bool` | `"true"` | no |
| <a name="input_index_document"></a> [index\_document](#input\_index\_document) | The name of the index document for the website | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key arn to encrypt s3 bucket if sse algorith is aws:kms | `string` | `null` | no |
| <a name="input_lambda_notifications"></a> [lambda\_notifications](#input\_lambda\_notifications) | List of Lambda function notifications | <pre>list(object({<br/>    lambda_function_arn = string<br/>    events              = list(string)<br/>    filter_prefix       = optional(string)<br/>    filter_suffix       = optional(string)<br/>    id                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | lifecycle rules for objects transition to different storage classes | <pre>list(object({<br/>    id     = string<br/>    status = string<br/>    prefix = string<br/>    expiration = optional(object({<br/>      days                         = optional(number)<br/>      date                         = optional(string)<br/>      expired_object_delete_marker = optional(bool)<br/>    }))<br/>    transition = optional(list(object({<br/>      days          = optional(number)<br/>      date          = optional(string)<br/>      storage_class = string<br/>    })))<br/>    noncurrent_version_expiration = optional(object({<br/>      noncurrent_days           = number<br/>      newer_noncurrent_versions = optional(number)<br/>    }))<br/>    noncurrent_version_transition = optional(list(object({<br/>      noncurrent_days           = number<br/>      storage_class             = string<br/>      newer_noncurrent_versions = optional(number)<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_location_name"></a> [location\_name](#input\_location\_name) | Name of the Availability Zone ID or Local Zone ID | `string` | `null` | no |
| <a name="input_location_type"></a> [location\_type](#input\_location\_type) | Location type for S3 directory bucket | `string` | `"AvailabilityZone"` | no |
| <a name="input_logging_bucket_name"></a> [logging\_bucket\_name](#input\_logging\_bucket\_name) | Destination bucket name to store S3 access logs | `string` | `null` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Enable logging | `bool` | `false` | no |
| <a name="input_object_lock_enabled"></a> [object\_lock\_enabled](#input\_object\_lock\_enabled) | Enable object locking in bucket | `bool` | `false` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Object ownership for bucket | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_redirect_all_requests_to"></a> [redirect\_all\_requests\_to](#input\_redirect\_all\_requests\_to) | Redirect all requests to another website | <pre>object({<br/>    host_name = string<br/>    protocol  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_replication_configuration"></a> [replication\_configuration](#input\_replication\_configuration) | Enable Replication Configuration | <pre>object({<br/>    role  = string<br/>    token = optional(string)<br/>    rule = list(object({<br/>      id       = string<br/>      status   = string<br/>      priority = optional(number)<br/>      filter = optional(object({<br/>        tag = optional(object({<br/>          key   = string<br/>          value = string<br/>        }))<br/>        tags   = optional(map(any))<br/>        prefix = optional(string)<br/>      }))<br/>      delete_marker_replication = optional(object({<br/>        status = string<br/>      }))<br/>      destination = object({<br/>        access_control_translation = optional(object({<br/>          owner = string<br/>        }))<br/>        account = optional(string)<br/>        bucket  = string<br/>        encryption_configuration = optional(object({<br/>          replica_kms_key_id = string<br/>        }))<br/>        metrics = optional(object({<br/>          status = string<br/>          event_threshold = optional(object({<br/>            minutes = number<br/>          }))<br/>        }))<br/>        replication_time = optional(object({<br/>          status = string<br/>          time = object({<br/>            minutes = number<br/>          })<br/>        }))<br/>        storage_class = optional(string)<br/>      })<br/>      source_selection_criteria = optional(object({<br/>        replica_modifications = optional(object({<br/>          status = string<br/>        }))<br/>        sse_kms_encrypted_objects = optional(object({<br/>          status = string<br/>        }))<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | restrict public bucket | `bool` | `"true"` | no |
| <a name="input_routing_rule"></a> [routing\_rule](#input\_routing\_rule) | Routing rule configuration for website | <pre>list(object({<br/>    condition = object({<br/>      http_error_code_returned_equals = optional(string)<br/>      key_prefix_equals               = optional(string)<br/>    })<br/>    redirect = object({<br/>      host_name               = optional(string)<br/>      http_redirect_code      = optional(string)<br/>      protocol                = optional(string)<br/>      replace_key_prefix_with = optional(string)<br/>      replace_key_with        = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_routing_rules"></a> [routing\_rules](#input\_routing\_rules) | Routing rules configuration for website | `string` | `""` | no |
| <a name="input_sns_notifications"></a> [sns\_notifications](#input\_sns\_notifications) | List of SNS topic notifications | <pre>list(object({<br/>    topic_arn     = string<br/>    events        = list(string)<br/>    filter_prefix = optional(string)<br/>    filter_suffix = optional(string)<br/>    id            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_sqs_notifications"></a> [sqs\_notifications](#input\_sqs\_notifications) | List of SQS queue notifications | <pre>list(object({<br/>    queue_arn     = string<br/>    events        = list(string)<br/>    filter_prefix = optional(string)<br/>    filter_suffix = optional(string)<br/>    id            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | server side encryption algorithm for bucket | `string` | `"AES256"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_use_bucket_prefix"></a> [use\_bucket\_prefix](#input\_use\_bucket\_prefix) | whether to use bucket prefix for the s3 bucket name | `bool` | `false` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Enable versioning for bucket | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The Amazon Resource Name (ARN) of the created S3 bucket. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The id/name of the created S3 bucket. |
| <a name="output_directory_bucket_arn"></a> [directory\_bucket\_arn](#output\_directory\_bucket\_arn) | The Amazon Resource Name (ARN) of the created S3 directory bucket. |
| <a name="output_directory_bucket_name"></a> [directory\_bucket\_name](#output\_directory\_bucket\_name) | The id/name of the created S3 directory bucket. |
| <a name="output_website_domain"></a> [website\_domain](#output\_website\_domain) | The domain of the S3 bucket website |
| <a name="output_website_endpoint"></a> [website\_endpoint](#output\_website\_endpoint) | The website endpoint of the S3 bucket |
<!-- END_TF_DOCS -->

## License

See LICENSE file for full details.

## Maintainers

* [Anish Kumar](https://github.com/anishkumarait)
* [Marcin Cuber](https://github.com/marcincuber)
* [Montek Singh](https://github.com/Montek30)

## Pre-commit hooks

### Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/segmentio/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.

#### MacOS

```bash
brew install pre-commit terraform-docs tflint

brew tap git-chglog/git-chglog
brew install git-chglog
```
