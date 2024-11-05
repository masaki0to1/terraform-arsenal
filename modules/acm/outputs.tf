output "virginia_cert" {
  value = {
    id  = aws_acm_certificate.virginia.id
    arn = aws_acm_certificate.virginia.arn
  }
}

output "tokyo_cert" {
  value = {
    id  = aws_acm_certificate.tokyo.id
    arn = aws_acm_certificate.tokyo.arn
  }
}
