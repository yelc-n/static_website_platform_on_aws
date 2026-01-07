# Module: frontend-s3
# Purpose: create an S3 bucket to store static website assets and enforce strict public access controls.
# Notes: Access is intended to be via CloudFront (OAC), so the bucket itself should not be publicly accessible.

resource "aws_s3_bucket" "frontend_bucket" {
  # Bucket name derived from the provided prefix for predictable naming
  bucket = "${var.bucket_name_prefix}-frontend-bucket"
}

# Block public access at the bucket level as a safety measure. CloudFront will access the bucket through OAC.
resource "aws_s3_bucket_public_access_block" "frontend_bucket_access_block" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
