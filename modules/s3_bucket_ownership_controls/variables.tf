variable "bucket_id" {
  description = "ID of S3 Bucket"
  type        = string
}

variable "object_ownership" {
  description = "Object ownership setting for S3 bucket"
  type        = string
  default     = "BucketOwnerPreferred"
  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.object_ownership)
    error_message = "object_ownership must be one of: 'BucketOwnerPreferred', 'ObjectWriter', 'BucketOwnerEnforced'"
  }
}