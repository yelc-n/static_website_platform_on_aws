# Local values for `dev`
# Purpose: compute derived values used within this environment for naming and DNS records.

locals {
  # Prefix to build consistent resource names across the environment
  resource_prefix = "${var.env}-${var.project_name}"

  # Tag value used for cost tracking and identification
  cost_env = "${var.env}-${var.project_name}"

  # All DNS domains to manage: root domain plus any subdomains (e.g., www.example.com)
  domains = concat(
    [var.root_domain_name],
    [
      for subdomain in var.sub_domain_names : "${subdomain}.${var.root_domain_name}"
    ]
  )
} 