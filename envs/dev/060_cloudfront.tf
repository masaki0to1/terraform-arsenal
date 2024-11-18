## CFD ##
# resources cfd
module "s3_bucket_cfd_resources" {
  source = "../../modules/cfd/s3_bucket_cfd"

  oac_name    = "${local.name_prefix}-resources-oac"
  domain_name = module.s3_bucket_resources_origin.attrs.bucket_regional_domain_name
  origin_id   = "${local.name_prefix}-resources-origin"

  price_class         = "PriceClass_200"
  default_root_object = "index.html"
  alias_domain        = ["resources.${var.domain}"]

  allowed_methods = ["GET", "HEAD"]
  cached_methods  = ["GET", "HEAD"]

  forward_query_string = false
  forward_cookies      = "none"

  viewer_protocol_policy = "redirect-to-https"
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400

  geo_restriction_type           = "none"
  cloudfront_default_certificate = false
  acm_certificate_arn            = module.acm.virginia_cert.arn
  ssl_support_method             = "sni-only"
  minimum_protocol_version       = "TLSv1.2_2019"
}

# admin cfd
module "landing_page_cfd_admin" {
  source = "../../modules/cfd/landing_page_cfd"

  func_name  = "${local.name_prefix}-basic-auth"
  runtime    = "cloudfront-js-2.0"
  comment    = "${local.name_prefix}-basic-auth"
  is_publish = true
  basic_auth_users = [
    { username = var.authuser_admin }
  ]
  basic_auth_user_pass_map = module.secret_authpass_admin.auth_user_pass_map

  oac_name    = "${local.name_prefix}-admin-oac"
  domain_name = module.s3_bucket_admin_origin.attrs.bucket_regional_domain_name
  origin_id   = "${local.name_prefix}-admin-origin"

  price_class         = "PriceClass_200"
  default_root_object = "index.html"
  alias_domain        = ["resources.${var.domain}"]

  allowed_methods = ["GET", "HEAD"]
  cached_methods  = ["GET", "HEAD"]

  forward_query_string = false
  forward_cookies      = "none"

  viewer_protocol_policy = "redirect-to-https"
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400

  geo_restriction_type           = "none"
  cloudfront_default_certificate = false
  acm_certificate_arn            = module.acm.virginia_cert.arn
  ssl_support_method             = "sni-only"
  minimum_protocol_version       = "TLSv1.2_2019"

  custom_error_responses = [
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    },
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 10
    }
  ]
}