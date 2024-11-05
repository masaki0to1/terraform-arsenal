resource "aws_cognito_user_pool" "this" {
  name = var.name

  # Setting to disable self-service account recovery: 
  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  # Password policy settings
  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    require_lowercase                = var.password_policy.require_lowercase
    require_uppercase                = var.password_policy.require_uppercase
    temporary_password_validity_days = var.password_policy.temporary_password_validity_days
  }

  # Schema settings
  dynamic "schema" {
    for_each = var.schema_attributes

    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = try(schema.value.developer_only_attribute, false)
      mutable                  = try(schema.value.mutable, true)
      required                 = try(schema.value.required, false)

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [1] : []
        content {
          min_length = try(schema.value.min_length, 0)
          max_length = try(schema.value.max_length, 2048)
        }
      }

      dynamic "number_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "Number" ? [1] : []
        content {
          min_value = try(schema.value.min_value, null)
          max_value = try(schema.value.max_value, null)
        }
      }
    }
  }
}

resource "aws_cognito_identity_provider" "this" {
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = var.provider_name
  provider_type = var.provider_type

  provider_details = {
    client_id                     = var.client_id
    client_secret                 = var.client_secret
    oidc_issuer                   = var.provider_details.oidc_issuer
    attributes_url                = var.provider_details.attributes_url
    attributes_url_add_attributes = var.provider_details.attributes_url_add_attributes
    attributes_request_method     = var.provider_details.attributes_request_method
    authorize_scopes              = var.provider_details.authorize_scopes
    authorize_url                 = var.provider_details.authorize_url
    token_url                     = var.provider_details.token_url
    jwks_uri                      = var.provider_details.jwks_uri
  }

  attribute_mapping = {
    email    = var.attribute_mapping.email
    username = var.attribute_mapping.username
    name     = var.attribute_mapping.name
  }

  idp_identifiers = var.idp_identifiers
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = var.client_name
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = var.generate_secret
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  supported_identity_providers         = [aws_cognito_identity_provider.this.provider_name]
  enable_token_revocation              = var.enable_token_revocation
  prevent_user_existence_errors        = var.prevent_user_existence_errors

  explicit_auth_flows = var.explicit_auth_flows

  refresh_token_validity = var.refresh_token_validity
  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity

  token_validity_units {
    access_token  = var.token_validity_units.access_token
    id_token      = var.token_validity_units.id_token
    refresh_token = var.token_validity_units.refresh_token
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain          = var.domain_name
  certificate_arn = var.certificate_arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.this.id
    provider_name           = aws_cognito_user_pool.this.endpoint
    server_side_token_check = var.server_side_token_check
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "this" {
  identity_pool_id = aws_cognito_identity_pool.this.id

  roles = {
    authenticated   = var.authenticated_role_arn
    unauthenticated = var.unauthenticated_role_arn
  }
}