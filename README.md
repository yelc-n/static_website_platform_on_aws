# Static Website Platform on AWS (Terraform) 🚀

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-blueviolet) ![AWS](https://img.shields.io/badge/AWS-Cloud-orange) ![IaC](https://img.shields.io/badge/IaC-Terraform-blue)

## Overview

This repository provides a reusable, production-ready template to host a static website on AWS using S3 + CloudFront with HTTPS and custom domains, fully managed via Terraform.

Designed to be:
- Safe to test (dev environment)
- Easy to reuse and extend as a template
- Aligned with AWS best practices (private S3, OAC, DNS validation)

---

## Architecture

Traffic flow:

```
User → Route53 (DNS) → CloudFront (CDN + HTTPS) → S3 (private via OAC)
```

Key components:
- S3: static content storage (private bucket)
- CloudFront: CDN + TLS termination
- ACM: TLS certificate (DNS validation)
- Route53: DNS records
- Terraform: infrastructure as code

---

## Notable changes (IMPORTANT)

- DNS validation for ACM has been **moved into `modules/acm`**. The ACM module now creates the required Route53 records directly using `aws_acm_certificate.cert.domain_validation_options`.
- The previous `modules/route53-acm-validation` has been **deprecated and removed** from the repo — this avoids the "Invalid for_each argument" planning error when validation options are only known after apply.
- CloudFront now depends on the ACM validation (module `route53_certs`) to ensure certificates are `ISSUED` before creating the distribution.
- Certificates used by CloudFront must be in **us-east-1**; the environments configure a provider alias `aws.us_east_1` for this purpose.

---

## Repo layout

```
infra/
├── environments/
│   ├── dev/   # example environment with terraform.tfvars
│   ├── stg/
│   └── prod/
└── modules/
    ├── frontend-s3/
    ├── cloudfront/
    └── acm/    # includes certificate request + DNS validation records
```

> Keep `terraform.tfvars.example` intact; use `terraform.tfvars` per environment for actual values.

---

## Prerequisites

- A Route53 hosted zone for the domain(s) you intend to use **must already exist** in the AWS account.
- This project **does NOT** create Route53 hosted zones or register domains; you are responsible for creating/managing the hosted zone and domain registration separately.
- Ensure AWS credentials are configured (AWS CLI/profile or env vars) for the account where you will apply the configuration.

---

## Quick start (per environment)

```bash
cd infra/environments/<env>
terraform init -upgrade
terraform plan
terraform apply
```

Notes:
- Validate `terraform.tfvars` contains the correct `root_domain_name`, `primary_zone_id`, and `sub_domain_names`.

---

## Common issues & diagnostics

- "Invalid for_each argument"
  - Cause: `for_each` was using keys derived from values only known after `apply` (certificate validation options).
  - Fix: validation records are now created inside the `acm` module so `for_each` keys come from local resource attributes and are known during plan.

- Certificate stuck in `PENDING_VALIDATION`
  - Check that Route53 records exist and `aws_acm_certificate_validation` resource has been created.

- "No valid credential sources found"
  - Ensure AWS credentials are configured: `aws configure` or `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` env vars.

---

## Maintenance notes

- When removing deprecated modules, always check `terraform state list` and destroy resources if present before deleting the module code.
- Keep `terraform.tfvars.example` as a template; do not commit secrets into `terraform.tfvars`.

---

## Possible improvements

The following are practical improvements you can add to make this template more robust, secure, and production-ready:

- **Logging & analytics**: Configure CloudFront access logs to an S3 bucket and analyze with Athena or ship logs to a centralized logging/analytics pipeline.
- **AWS WAF**: Add WAF with managed rules to mitigate common web attacks (OWASP rules, IP reputation lists).
- **Monitoring & alerts**: Create CloudWatch metrics and alarms (e.g., 4xx/5xx spikes, origin errors) and notify via SNS (email/Slack).
- **CI/CD pipeline**: Add GitHub Actions / GitLab CI to run `terraform fmt`, `validate`, `plan` and optionally a gated `apply` for production.
- **Remote state & locking**: Use an S3 backend with DynamoDB state locking for team-safe operations (or Terraform Cloud).
- **Performance**: Enable image optimization (CloudFront Image Optimization or Lambda@Edge), Brotli/Gzip compression, and fine-grained cache policies.
- **Testing & linting**: Add automated tests (terratest / kitchen-terraform) and static checks (tflint, tfsec) as part of CI.
- **Disaster recovery**: Add origin failover (multi-region origins or replication), state backups, and documented recovery procedures.

---

## License

Use this project for learning and internal templates. Feel free to fork and adapt.

