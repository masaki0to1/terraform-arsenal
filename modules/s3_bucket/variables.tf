variable "bucket_name" {
  description = "Name of S3 Bucket"
  type        = string
}

variable "enable_cors" {
  description = "Flag to enable/disable CORS configuration for the S3 bucket"
  type        = bool
  default     = false
}

variable "cors_rules" {
  description = "CORS rule config"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = [{
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }]
}
