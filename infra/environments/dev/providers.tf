# Terraform provider configuration for `dev` environment
# Purpose: configure required providers (AWS) and set default tags applied to all AWS resources.
# Notes:
# - Keep provider versions pinned to ensure reproducible plans.
# - Default tags help with cost allocation and resource identification.

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider: sets the region and attaches a set of default tags to all created AWS resources.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      # Basic tags that will be applied to all AWS resources for this environment
      Environment = var.env
      Project     = var.project_name
      CostCenter  = var.project_name
      CostEnv     = local.cost_env
      ManagedBy   = "Terraform"
    }
  }
} 