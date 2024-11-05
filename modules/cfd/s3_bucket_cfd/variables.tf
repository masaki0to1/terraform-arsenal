variable "oac_name" {
  description = "Name of CloudFront Origin Access Control"
  type        = string
}

variable "origin_type" {
  type        = string
  description = "Type of origin that this Origin Access Control is for"
  default     = "s3"
}

variable "signing_behavior" {
  type        = string
  description = "Specifies how CloudFront signs requests"
  default     = "always"
}

variable "signing_protocol" {
  type        = string
  description = "Protocol that CloudFront uses to sign requests"
  default     = "sigv4"
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Object that CloudFront returns when an end user requests the root URL"
  type        = string
  default     = null
}

variable "alias_domain" {
  description = "List of alternate domain names for the distribution"
  type        = list(string)
  default     = null
}

variable "price_class" {
  description = "Price class for the distribution (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_All"
}

variable "domain_name" {
  description = "Domain name of the origin"
  type        = string
}

variable "origin_id" {
  description = "Unique identifier for the origin"
  type        = string
}

variable "allowed_methods" {
  description = "HTTP methods that CloudFront processes and forwards to your origin"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "HTTP methods that CloudFront caches responses from your origin"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "forward_query_string" {
  description = "Whether to forward query strings to the origin"
  type        = bool
  default     = false
}

variable "forward_cookies" {
  description = "Specifies how CloudFront handles cookies"
  type        = string
  default     = "none"
}

variable "viewer_protocol_policy" {
  description = "Protocol that users can use to access the files"
  type        = string
  default     = "redirect-to-https"
}

variable "min_ttl" {
  description = "Minimum amount of time objects stay in CloudFront cache"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default amount of time objects stay in CloudFront cache"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum amount of time objects stay in CloudFront cache"
  type        = number
  default     = 86400
}

variable "geo_restriction_type" {
  description = "Method to use for geographic restrictions"
  type        = string
  default     = "none"
}

variable "cloudfront_default_certificate" {
  description = "Whether to use the default CloudFront certificate"
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate to use with the distribution"
  type        = string
  default     = null
}

variable "ssl_support_method" {
  description = "How CloudFront serves HTTPS requests"
  type        = string
  default     = null
}

variable "minimum_protocol_version" {
  description = "Minimum version of the SSL protocol for HTTPS"
  type        = string
  default     = null
}
