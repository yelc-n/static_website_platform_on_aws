# Module: acm
# Purpose: request an ACM certificate for a root domain and optional SANs (subdomains) using DNS validation.
# Notes: This module only requests the certificate; DNS validation records are expected to be created by
# the route53-acm-validation module.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.root_domain_name
  validation_method = "DNS"

  # Higher-level subject alternative names (subdomains) to secure using the same cert
  subject_alternative_names = [
    for subdomain in var.sub_domain_name : "${subdomain}.${var.root_domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records in the provided hosted zone using the
# domain validation options returned by ACM. We create these here so the
# for_each keys are known to Terraform during planning (they depend on
# the certificate resource in this same module).
resource "aws_route53_record" "validation" {
  for_each = { for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => dvo }

  zone_id = var.host_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 60
  records = [each.value.resource_record_value]
  allow_overwrite = true
}

# Wait for the certificate to be issued once the DNS records exist
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
} 