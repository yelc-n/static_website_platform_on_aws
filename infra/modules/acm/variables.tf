variable "host_zone_id" {
  description = "The ID of the Hosted Zone in Route 53"
  type        = string
}

variable "root_domain_name" {
  description = "The domain name for which the ACM certificate will be requested"
  type        = string
}

variable "sub_domain_name" {
  description = "The subdomain name for which the ACM certificate will be requested"
  type        = list(string)
}