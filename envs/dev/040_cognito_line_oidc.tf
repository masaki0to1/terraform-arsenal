module "cognito_line_oidc" {
  source = "../../modules/cognito"

  # User Pool settings
  name = "${local.name_prefix}-line-user-pool"
  password_policy = {
    minimum_length                   = 8
    require_numbers                  = true
    require_symbols                  = true
    require_lowercase                = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # Schema attributes
  schema_attributes = [
    {
      name                     = "email"
      attribute_data_type      = "String"
      developer_only_attribute = false
      required                 = false
      mutable                  = true

      string_attribute_constraints = {
        min_length = 3
        max_length = 2048
      }
    },
    {
      name                     = "phone_number"
      attribute_data_type      = "String"
      developer_only_attribute = false
      required                 = false
      mutable                  = true

      string_attribute_constraints = {
        min_length = 0
        max_length = 2048
      }
    },
    {
      name                     = "birthdate"
      attribute_data_type      = "String"
      developer_only_attribute = false
      required                 = false
      mutable                  = true

      string_attribute_constraints = {
        min_length = 10
        max_length = 10
      }
    }
  ]

  # Identity Providers
  identity_providers = {
    line = {
      provider_name = "line"
      provider_type = "OIDC"
      provider_details = {
        oidc_issuer                   = "https://access.line.me"
        attributes_url                = "https://api.line.me/oauth2/v2.1/userinfo"
        attributes_url_add_attributes = false # for LINE OIDC
        attributes_request_method     = "GET"
        authorize_scopes              = "email openid profile"
        authorize_url                 = "https://access.line.me/oauth2/v2.1/authorize"
        token_url                     = "https://api.line.me/oauth2/v2.1/token"
        jwks_uri                      = "https://api.line.me/oauth2/v2.1/certs"
        client_id                     = var.line_client_id
        client_secret                 = var.line_client_secret
      }
      attribute_mapping = {
        email    = "email"
        username = "sub"
        name     = "name"
        picture  = "picture"
      }
    }
  }

  # User Pool Clients
  clients = {
    line = {
      name                 = "${local.name_prefix}-line-user-client"
      allowed_oauth_scopes = ["email", "openid", "profile"]
      callback_urls = [
        "http://localhost:3000/sign-in",
        "https://${var.domain}/sign-in"
      ]
      logout_urls = [
        "http://localhost:3000",
        "https://${var.domain}"
      ]
      generate_secret                      = true # for backend
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_flows_user_pool_client = true
      enable_token_revocation              = true
      prevent_user_existence_errors        = "ENABLED"
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_CUSTOM_AUTH"
      ]
      refresh_token_validity = 30
      access_token_validity  = 1
      id_token_validity      = 1
      token_validity_units = {
        access_token  = "hours"
        id_token      = "hours"
        refresh_token = "days"
      }
    }
  }

  # Domains
  domains = {
    main = {
      domain_name     = "${local.name_prefix}-sample-domain"
      certificate_arn = module.acm.tokyo_cert.arn
    }
  }

  # Identity Pool settings
  create_identity_pool = true
  identity_pool_name   = "${local.name_prefix}-identity-pool"

  identity_pool_config = {
    allow_unauthenticated_identities = false
    server_side_token_check          = true
  }

  identity_pool_roles = {
    authenticated_role_arn   = module.iam_role_cognito_auth.attrs.arn
    unauthenticated_role_arn = null
  }
}