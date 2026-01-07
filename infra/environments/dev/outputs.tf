# Outputs for `dev` environment
# Purpose: expose commonly used values (for use by scripts, CI/CD, or other Terraform stacks).

output "environment" {
  description = "Current environment"
  value       = var.env
}

# Project name output so other modules or external tooling can reference it.
output "project_name" {
  description = "Project name"
  value       = var.project_name
}

# Resource prefix (constructed from env and project name) used for consistent naming.
output "resource_prefix" {
  description = "Prefix used for resource naming"
  value       = local.resource_prefix
}

# Expose the cost environment tag value for use in reporting or external systems.
output "cost_env_tag" {
  description = "Cost environment tag value"
  value       = local.cost_env
}
