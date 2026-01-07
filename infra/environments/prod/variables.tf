# Variables for the `dev` environment
# Purpose: define configurable values for this environment. Keep values clear and environment-specific.

# The current environment label (e.g., dev, stg, prod). Used for naming and tagging resources.
variable "env" {
  description = "Actual environment (dev, stg, prod)"
  type        = string
}

# Friendly project name used for tags and naming resources.
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# AWS region where resources will be created for this environment.
variable "region" {
  description = "Region of the project"
  type        = string
  default     = "us-east-1"
}

# Route53 hosted zone ID for the primary DNS zone used by this project.
variable "primary_zone_id" {
  description = "The ID of the Primary Hosted Zone on Route 53"
  type        = string
}

# Root domain name for the project (e.g., example.com). Used for ACM and DNS records.
variable "root_domain_name" {
  description = "The root domain name for the project"
  type        = string
}

# List of subdomain prefixes (e.g., ["www","app"]). These will be combined with the root domain.
variable "sub_domain_names" {
  description = "List of sub domain names for the project"
  type        = list(string)
  default     = []
}