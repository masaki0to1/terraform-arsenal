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

  # Identity Provider settings
  provider_name = local.cognito_conf.line_identity_provider.name
  provider_type = local.cognito_conf.line_identity_provider.type
  client_id     = var.line_client_id
  client_secret = var.line_client_secret

  provider_details = local.cognito_conf.line_identity_provider.details

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
  }

  # User Pool Client settings
  client_name          = "${local.name_prefix}-line-user-client"
  allowed_oauth_scopes = ["email", "openid", "profile"]
  callback_urls = [
    "http://localhost:3000/sign-in",
    "https://${var.domain}/sign-in"
  ]
  logout_urls = [
    "http://localhost:3000",
    "https://${var.domain}"
  ]
  generate_secret                      = local.cognito_conf.user_pool_client.generate_secret
  allowed_oauth_flows                  = local.cognito_conf.user_pool_client.allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = local.cognito_conf.user_pool_client.allowed_oauth_flows_user_pool_client
  enable_token_revocation              = local.cognito_conf.user_pool_client.enable_token_revocation
  prevent_user_existence_errors        = local.cognito_conf.user_pool_client.prevent_user_existence_errors

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

  # Domain settings
  domain_name     = var.user_pool_domain
  certificate_arn = module.acm.tokyo_cert.arn

  # Identity Pool settings
  identity_pool_name               = "${local.name_prefix}-identity-pool"
  allow_unauthenticated_identities = false
  server_side_token_check          = true

  # Role ARNs
  authenticated_role_arn   = module.iam_role_cognito_auth.attrs.arn
  unauthenticated_role_arn = null
}