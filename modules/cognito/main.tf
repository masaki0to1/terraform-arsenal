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

  # Additional User Pool settings using dynamic blocks
  dynamic "verification_message_template" {
    for_each = var.verification_message_template != null ? [var.verification_message_template] : []
    content {
      default_email_option = try(verification_message_template.value.default_email_option, "CONFIRM_WITH_CODE")
      email_subject        = try(verification_message_template.value.email_subject, null)
      email_message        = try(verification_message_template.value.email_message, null)
      sms_message          = try(verification_message_template.value.sms_message, null)
    }
  }
}

# Identity Providers
resource "aws_cognito_identity_provider" "this" {
  for_each = var.identity_providers

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = each.value.provider_name
  provider_type = each.value.provider_type

  provider_details  = each.value.provider_details
  attribute_mapping = each.value.attribute_mapping
  idp_identifiers   = try(each.value.idp_identifiers, [])
}

# User Pool Clients
resource "aws_cognito_user_pool_client" "this" {
  for_each = var.clients

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id

  # 基本設定
  generate_secret                      = try(each.value.generate_secret, false)
  allowed_oauth_flows                  = try(each.value.allowed_oauth_flows, [])
  allowed_oauth_flows_user_pool_client = try(each.value.allowed_oauth_flows_user_pool_client, true)
  allowed_oauth_scopes                 = try(each.value.allowed_oauth_scopes, [])
  callback_urls                        = try(each.value.callback_urls, [])
  logout_urls                          = try(each.value.logout_urls, [])
  supported_identity_providers         = try(each.value.supported_identity_providers, keys(aws_cognito_identity_provider.this))

  # トークン設定
  refresh_token_validity = try(each.value.refresh_token_validity, 30)
  access_token_validity  = try(each.value.access_token_validity, 1)
  id_token_validity      = try(each.value.id_token_validity, 1)

  dynamic "token_validity_units" {
    for_each = try(each.value.token_validity_units, null) != null ? [each.value.token_validity_units] : []
    content {
      access_token  = try(token_validity_units.value.access_token, "hours")
      id_token      = try(token_validity_units.value.id_token, "hours")
      refresh_token = try(token_validity_units.value.refresh_token, "days")
    }
  }

  # その他のオプション設定
  enable_token_revocation       = try(each.value.enable_token_revocation, true)
  prevent_user_existence_errors = try(each.value.prevent_user_existence_errors, "ENABLED")
  explicit_auth_flows           = try(each.value.explicit_auth_flows, [])
}

# Domains
resource "aws_cognito_user_pool_domain" "this" {
  for_each = var.domains

  domain          = each.value.domain_name
  certificate_arn = try(each.value.certificate_arn, null)
  user_pool_id    = aws_cognito_user_pool.this.id
}

# Identity Pool
resource "aws_cognito_identity_pool" "this" {
  count = var.create_identity_pool ? 1 : 0

  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = try(var.identity_pool_config.allow_unauthenticated_identities, false)

  dynamic "cognito_identity_providers" {
    for_each = var.clients
    content {
      client_id               = aws_cognito_user_pool_client.this[cognito_identity_providers.key].id
      provider_name           = aws_cognito_user_pool.this.endpoint
      server_side_token_check = try(var.identity_pool_config.server_side_token_check, true)
    }
  }
}

# Identity Pool Roles
resource "aws_cognito_identity_pool_roles_attachment" "this" {
  depends_on = [aws_cognito_identity_pool.this]
  count      = var.create_identity_pool ? 1 : 0

  identity_pool_id = aws_cognito_identity_pool.this[0].id

  roles = {
    authenticated   = var.identity_pool_roles.authenticated_role_arn
    unauthenticated = try(var.identity_pool_roles.unauthenticated_role_arn, null)
  }
}