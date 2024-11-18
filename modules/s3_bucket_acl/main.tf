resource "aws_s3_bucket_acl" "this" {
  bucket = var.bucket_id
  acl    = var.acl
}
