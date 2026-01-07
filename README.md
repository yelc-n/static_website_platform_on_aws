# Static Website Platform on AWS (Terraform)

## Overview

This project provides a **production-ready, cost-aware template** for hosting a **static website** on AWS using **Amazon S3 + Amazon CloudFront** with **HTTPS** and **custom domains**, fully automated with **Terraform**.

The repository is designed to be:

* **Safe to test** (no immediate costs when applied with low/no traffic)
* **Reusable** as a template
* **Easy to understand** for other engineers
* **Aligned with AWS best practices** (private S3, OAC, DNS validation)

---

## Architecture

**Traffic Flow**:

```
User → Route53 (DNS)
     → CloudFront (CDN + HTTPS)
     → S3 (private bucket via OAC)
```

**Key Components**:

* **Amazon S3**: Stores static files (private bucket)
* **Amazon CloudFront**: CDN and HTTPS termination
* **AWS ACM**: TLS certificate (DNS validated)
* **Amazon Route53**: DNS records
* **Terraform**: Infrastructure as Code

---

## Repository Structure

```
infra/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── locals.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   └── stg/
└── modules/
    ├── frontend-s3/
    ├── cloudfront/
    ├── acm/
    └── route53-acm-validation/
```

Each **environment** is an independent Terraform root module (no workspaces).

---

## Design Principles

### 1. Separation of Responsibilities

* **S3 module**: Only storage
* **ACM module**: Only certificate creation
* **Route53 validation module**: Only DNS validation
* **CloudFront module**: CDN configuration only
* **Root module**: Orchestration

### 2. Security First

* S3 bucket is **private**
* Access only via **CloudFront Origin Access Control (OAC)**
* No public ACLs or bucket policies in modules

### 3. Cost Awareness

* No compute services
* CloudFront uses **pay-as-you-go** by default
* No costs unless traffic occurs

---

## Environment: `dev`

The `dev` environment is fully functional and can be applied safely.

### Required Variables (`terraform.tfvars`)

```hcl
root_domain_name   = "example.com"
sub_domain_names   = ["www", "app"]
primary_zone_id    = "ZXXXXXXXXXXXX"
```

> ⚠️ The hosted zone **must already exist** in Route53.

---

## How HTTPS Works

1. ACM requests a certificate
2. DNS validation records are created in Route53
3. ACM certificate becomes **ISSUED**
4. CloudFront uses the certificate
5. Route53 A (ALIAS) records point domains to CloudFront

---

## Applying the Infrastructure

```bash
cd infra/environments/dev
terraform init
terraform plan
terraform apply
```

To remove everything created by this project:

```bash
terraform destroy
```

> This **will NOT delete your hosted zone or domain**.

---

## Extending This Project

Possible improvements:

* IPv6 (AAAA records)
* CloudFront access logs
* AWS WAF
* CI/CD pipeline
* ~~Multiple environments (stg/prod)~~ (added briefly after pushing)

---

## License / Usage

This project is intended for:

* Learning Terraform
* Portfolio demonstration
* Internal templates

Feel free to fork and adapt.
