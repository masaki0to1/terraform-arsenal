output "attrs" {
  value = {
    identity_pool_id = aws_cognito_identity_pool.this.id
  }
}