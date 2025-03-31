output "bucket_id" {
  value       = var.create_bucket ? aws_s3_bucket.main[0].id : null
  description = "The id/name of the created S3 bucket."
}

output "bucket_arn" {
  value       = var.create_bucket ? aws_s3_bucket.main[0].arn : null
  description = "The Amazon Resource Name (ARN) of the created S3 bucket."
}

output "website_domain" {
  value       = var.enable_website_configuration ? aws_s3_bucket_website_configuration.main[0].website_domain : null
  description = "The domain of the S3 bucket website"
}

output "website_endpoint" {
  value       = var.enable_website_configuration ? aws_s3_bucket_website_configuration.main[0].website_endpoint : null
  description = "The website endpoint of the S3 bucket"
}

output "directory_bucket_name" {
  value       = var.create_directory_bucket ? aws_s3_directory_bucket.main[0].bucket : null
  description = "The id/name of the created S3 directory bucket."
}

output "directory_bucket_arn" {
  value       = var.create_directory_bucket ? aws_s3_directory_bucket.main[0].arn : null
  description = "The Amazon Resource Name (ARN) of the created S3 directory bucket."
}
