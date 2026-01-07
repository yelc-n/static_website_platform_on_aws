# Module: acm
# Purpose: request an ACM certificate for a root domain and optional SANs (subdomains) using DNS validation.
# Notes: This module only requests the certificate; DNS validation records are expected to be created by
# the route53-acm-validation module.

resource "aws_acm_certificate" "cert" {
  domain_name       = var.root_domain_name
  validation_method = "DNS"

  # Higher-level subject alternative names (subdomains) to secure using the same cert
  subject_alternative_names = var.sub_domain_name

  lifecycle {
    create_before_destroy = true
  }
} 