resource "aws_s3_bucket_acl" "this" {
  bucket = var.bucket_id
  acl = var.acl
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = var.bucket_id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}