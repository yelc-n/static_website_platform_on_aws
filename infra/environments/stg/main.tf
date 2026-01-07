# Environment-specific Terraform for the `dev` environment
# Purpose: wire together the S3 frontend bucket, CloudFront CDN, ACM certificates,
# and Route53 DNS records so the static website is hosted and served securely.

# Module: frontend
# - Purpose: Create an S3 bucket to store the static website assets (HTML, CSS, JS, images).
# - Exposes outputs (name, arn, regional domain) used by CloudFront and bucket policy.
module "frontend" {
  source             = "../../modules/frontend-s3"
  bucket_name_prefix = local.resource_prefix
}

# Module: cloudfront
# - Purpose: Create a CloudFront distribution to serve content from the S3 origin.
# - Uses Origin Access Control (OAC) and the ACM certificate for HTTPS and custom domain aliases.
# - The module consumes the S3 bucket outputs and the ACM certificate ARN.
module "cloudfront" {
  source                   = "../../modules/cloudfront"
  front_bucket_name        = module.frontend.front_bucket_name
  front_bucket_arn         = module.frontend.front_bucket_arn
  front_bucket_domain_name = module.frontend.front_bucket_regional_domain_name
  cdn_distro_oac_name      = "${local.resource_prefix}-oac"
  certificate_arn          = module.route53_certs.certificate_arn
  # Aliases: include the root domain and all configured subdomains as CloudFront CNAMEs
  aliases = concat(
    [var.root_domain_name],
    [
      for subdomain in var.sub_domain_names : "${subdomain}.${var.root_domain_name}"
    ]
  )
  depends_on = [ module.route53_certs ]
}

# Resource: aws_s3_bucket_policy.frontend_bucket_policy
# - Purpose: Grant CloudFront read access (s3:GetObject) to the S3 bucket objects.
# - Restricts access by requiring requests to originate from the specific CloudFront distribution (SourceArn).
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = module.frontend.front_bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.frontend.front_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.cloudfront_arn
          }
        }
      }
    ]
  })
}

# Resource: aws_route53_zone.primary_zone
# - Purpose: Reference (or create) the Route53 hosted zone for the site's domain in this environment.
# - This zone is used to create DNS records and to validate ACM certificates via DNS.
# resource "aws_route53_zone" "primary_zone" {
#   name    = var.route53_zone_name
##   zone_id = var.primary_zone_id
# }

# Module: route53_certs
# - Purpose: Request ACM certificates for the root domain and subdomains and perform DNS validation
#   using the provided Route53 hosted zone.
module "route53_certs" {

  providers = {
    aws = aws.us_east_1
  }
  source           = "../../modules/acm"
  host_zone_id     = var.primary_zone_id
  root_domain_name = var.root_domain_name
  sub_domain_name  = var.sub_domain_names
}

# Resource: aws_route53_record.cdn_records
# - Purpose: Create Route53 A (alias) records for each domain (root + subdomains) to point
#   at the CloudFront distribution. Uses the CloudFront domain name and hosted zone id for the alias.
resource "aws_route53_record" "cdn_records" {
  zone_id  = var.primary_zone_id
  for_each = toset(local.domains)
  name     = each.value
  type     = "A"
  alias {
    name                   = module.cloudfront.cloudfront_domain_name
    zone_id                = module.cloudfront.cdn_host_zone_id
    evaluate_target_health = false
  }
}