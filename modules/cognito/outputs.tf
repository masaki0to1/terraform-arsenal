output "attrs" {
  value = {
    identity_pool_id = aws_cognito_identity_pool.this[0].id
    user_pool_domain = length(aws_cognito_user_pool_domain.this) > 0 ? {
      for key, domain in aws_cognito_user_pool_domain.this : key => domain.cloudfront_distribution_arn
    } : {}
  }
}
