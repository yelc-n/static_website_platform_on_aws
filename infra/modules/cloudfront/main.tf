# Module: cloudfront
# Purpose: create a CloudFront distribution that serves content from the S3 origin using an OAC and an ACM certificate.
# Notes: The OAC ensures secure access from CloudFront to the protected S3 bucket.

resource "aws_cloudfront_origin_access_control" "cdn_oac" {
  name                              = var.cdn_distro_oac_name
  description                       = "Origin Access Control for CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution that points to the provided S3 origin and uses the OAC for origin access
resource "aws_cloudfront_distribution" "cdn_distro" {
  origin {
    domain_name              = var.front_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn_oac.id
    origin_id                = "FrontendS3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Aliases: list of domain names (root + subdomains) the distribution will serve
  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "FrontendS3Origin"

    # Redirect HTTP requests to HTTPS
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      // locations can be used to restrict distribution to specific countries
      //locations = [ "US", "CA", "BR", "GB", "FR", "DE", "IN", "JP", "AU" ]
    }
  }

  viewer_certificate {
    # The distribution uses the provided ACM certificate ARN (or CloudFront default if appropriate)
    cloudfront_default_certificate = var.certificate_arn
    ssl_support_method             = "sni-only"
  }
}