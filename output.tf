output "bucket_id" {
  value       = aws_s3_bucket.bucket.id
  description = "The id/name of the created S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "The Amazon Resource Name (ARN) of the created S3 bucket."
}
