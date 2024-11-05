variable "bucket_id" {
  description = "ID of S3 Bucket"
  type        = string
}

variable "policy_statements" {
  description = "S3 bucket policy statements"
  type        = list(any)
  default     = []
}
