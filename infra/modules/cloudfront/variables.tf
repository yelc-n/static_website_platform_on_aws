variable "front_bucket_name" {
  description = "The frontend S3 bucket's name"
  type        = string
}

variable "front_bucket_arn" {
  description = "The frontend S3 bucket's ARN"
  type        = string
}

variable "cdn_distro_oac_name" {
  description = "The name of the CloudFront distribution OAC"
  type        = string
}

variable "front_bucket_domain_name" {
  description = "The frontend S3 bucket's domain name"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the certificate used by CloudFront"
  type        = string
}

variable "aliases" {
  description = "The aliases which are used by CloudFront"
  type        = list(string)
}