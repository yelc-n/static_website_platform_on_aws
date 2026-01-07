output "cloudfront_arn" {
  description = "ARN of Cloudfront"
  value       = aws_cloudfront_distribution.cdn_distro.arn
}

output "cloudfront_id" {
  description = "ID of Cloudfront"
  value       = aws_cloudfront_distribution.cdn_distro.id
}

output "cloudfront_domain_name" {
  description = "Domain name of Cloudfront"
  value       = aws_cloudfront_distribution.cdn_distro.domain_name
}

output "cdn_host_zone_id" {
  description = "The ID of the Host Zone of CloudFront"
  value       = aws_cloudfront_distribution.cdn_distro.hosted_zone_id
}