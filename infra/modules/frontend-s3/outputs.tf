output "front_bucket_name" {
  description = "Name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend_bucket.id
}

output "front_bucket_arn" {
  description = "ARN of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend_bucket.arn
}

output "front_bucket_regional_domain_name" {
  description = "Regional domain name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
}