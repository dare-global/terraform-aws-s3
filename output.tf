output "bucket_id" {
  value       = aws_s3_bucket.main.id
  description = "The id/name of the created S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.main.arn
  description = "The Amazon Resource Name (ARN) of the created S3 bucket."
}

output "webiste_domain" {
  value       = aws_s3_bucket_website_configuration.main.website_domain
  description = "The domain of the website endpoint."
}

output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.main.website_endpoint
  description = "Website Endpoint."
}