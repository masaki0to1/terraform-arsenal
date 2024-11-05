output "attrs" {
  value = {
    domain_name = aws_cloudfront_distribution.this.domain_name
    arn = aws_cloudfront_distribution.this.arn
    hosted_zone_id = aws_cloudfront_distribution.this.hosted_zone_id
    oac_id = aws_cloudfront_origin_access_control.this.id
  }
}