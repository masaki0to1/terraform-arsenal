locals {
  basic_auth_credentials = jsonencode({
    for user in var.basic_auth_users :
    user.username => var.basic_auth_passwords[user.username]
  })
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.oac_name
  origin_access_control_origin_type = var.origin_type
  signing_behavior                  = var.signing_behavior
  signing_protocol                  = var.signing_protocol
}

resource "aws_cloudfront_function" "this" {
  name    = var.func_name
  runtime = var.runtime
  comment = var.comment
  publish = var.is_publish
  code    = <<-EOT
function hander(event) {
  var request = event.request;
  var headers = request.headers;
  var uri = request.uri;
  var authHeader = headers.authorization;
  var credentials = JSON.parse('${local.basic_auth_credentials}');

  // Basic Authentication Check
  if (typeof authHeader == 'undefined') {
    return {
      statusCode: 401,
      statusDescription: 'Unauthorized',
      headers: {
        'www-authenticate': { value: 'Basic' }
      }
    };
  }

  var encodedCreds = authHeader.value.split(' ')[1];
  var decodedCreds = atob(encodedCreds);
  var credParts = decodedCreds.split(':');
  var username = credParts[0];
  var password = credParts[1];

  if (credentials[username] !== password) {
    return {
      statusCode: 401,
      statusDescription: 'Unauthorized',
      headers: {
        'www-authenticate': { value: 'Basic' }
      }
    };
  }

// If authentication is successful, check and modify the URI

// Check whether the URI is missing a file name
if (uri.endsWith('/')) {
  request.uri += 'index.html';
}

// Check whether the URI is missing a file extension
else if (!uri.includes('.')) {
  request.uri += '/index.html';
}
return request;
}
EOT
}


resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object
  aliases             = var.alias_domain
  price_class         = var.price_class

  origin {
    domain_name              = var.domain_name
    origin_id                = var.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = var.forward_query_string
      cookies {
        forward = var.forward_cookies
      }
    }

    function_association {
      event_type   = var.event_type
      function_arn = aws_cloudfront_function.this.arn
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.ssl_support_method
    minimum_protocol_version       = var.minimum_protocol_version
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses != null ? var.custom_error_responses : []
    content {
      error_code            = custom_error_responses.value.error_code
      response_code         = custom_error_responses.value.response_code
      response_page_path    = custom_error_responses.value.response_page_path
      error_caching_min_ttl = custom_error_responses.value.error_caching_min_ttl
    }
  }
}