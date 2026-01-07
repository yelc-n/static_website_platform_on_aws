# Module: route53-acm-validation
# Purpose: create Route53 DNS records required to validate ACM certificates via DNS
# Usage: expects `validation_options` from `aws_acm_certificate` and will create the correct DNS records.

resource "aws_route53_record" "records" {
  zone_id = var.route53_zone_id
  # Create a record for each validation option returned by ACM for DNS validation
  for_each = {
    for validation in var.validation_options : validation.domain_name => validation
  }

  # The record name, type and value are provided by the ACM validation options
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  ttl             = 60
  records         = [each.value.resource_record_value]
  allow_overwrite = true
}

# Wait for ACM certificate to be validated using the created Route53 records
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = var.certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.records : record.fqdn]
} 