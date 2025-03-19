output "bucket_id" {
  value       = aws_s3_bucket.main.id
  description = "The id/name of the created S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.main.arn
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
