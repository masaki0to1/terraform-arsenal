resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = var.bucket_id
  rule {
    object_ownership = var.object_ownership
  }
}