variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID where the validation records will be created"
  type        = string
}

variable "validation_options" {
  description = "The Domain Validation Options received from ACM"
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}

variable "certificate_arn" {
  description = "The Certificate's ARN"
  type        = string
}