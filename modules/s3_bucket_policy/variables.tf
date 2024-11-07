variable "bucket_id" {
  description = "ID of S3 Bucket"
  type        = string
}

variable "policy_statements" {
  description = "S3 bucket policy statements"
  type = list(object({
    Sid       = string
    Effect    = string
    Principal = map(string)
    Action    = list(string)
    Resource  = list(string)
    Condition = map(map(string))
  }))
  default = []
}
