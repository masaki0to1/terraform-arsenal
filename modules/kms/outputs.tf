output "attrs" {
  value = {
    key_alias_arn = aws_kms_alias.this.arn
  }
}