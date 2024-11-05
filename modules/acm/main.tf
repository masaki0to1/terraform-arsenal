resource "aws_acm_certificate" "virginia" {
  provider                  = aws.virginia
  validation_method         = var.acm_conf.method
  domain_name               = var.domain
  subject_alternative_names = var.san

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "tokyo" {
  provider                  = aws
  validation_method         = var.acm_conf.method
  domain_name               = var.domain
  subject_alternative_names = var.san

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "dvo" {
  provider = aws.route53
  for_each = {
    for dvo in aws_acm_certificate.virginia.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  zone_id         = var.acm_conf.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = var.acm_conf.dvo_record_ttl
}

resource "aws_acm_certificate_validation" "validation" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.virginia.arn
  validation_record_fqdns = [for record in aws_route53_record.dvo : record.fqdn]
}
