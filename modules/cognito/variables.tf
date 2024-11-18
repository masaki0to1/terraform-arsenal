variable "name" {
  type        = string
  description = "Name of the Cognito user pool"
}

variable "password_policy" {
  description = "Password policy for the user pool"
  type = object({
    minimum_length                   = number
    require_numbers                  = bool
    require_symbols                  = bool
    require_lowercase                = bool
    require_uppercase                = bool
    temporary_password_validity_days = number
  })

  default = {
    minimum_length                   = 8
    require_numbers                  = true
    require_symbols                  = true
    require_lowercase                = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  validation {
    condition     = var.password_policy.minimum_length >= 8
    error_message = "minimum_length must be at least 8 characters"
  }

  validation {
    condition     = var.password_policy.temporary_password_validity_days >= 1 && var.password_policy.temporary_password_validity_days <= 365
    error_message = "temporary_password_validity_days must be between 1 and 365"
  }
}

variable "schema_attributes" {
  description = "Schema attribute settings for the user pool"
  type = list(object({
    name                     = string
    attribute_data_type      = string
    developer_only_attribute = optional(bool)
    mutable                  = optional(bool)
    required                 = optional(bool)
    string_attribute_constraints = optional(object({
      min_length = number
      max_length = number
    }))
    number_attribute_constraints = optional(object({
      min_value = number
      max_value = number
    }))
  }))
}

variable "verification_message_template" {
  description = "Configuration for verification message templates"
  type = object({
    default_email_option = optional(string)
    email_subject        = optional(string)
    email_message        = optional(string)
    sms_message          = optional(string)
  })
  default = null
}

variable "identity_providers" {
  description = "Map of identity providers configuration"
  type = map(object({
    provider_name     = string
    provider_type     = string
    provider_details  = any # Set to 'any' to support different identity providers
    attribute_mapping = map(string)
    idp_identifiers   = optional(list(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.identity_providers :
      contains(["OIDC", "SAML", "Facebook", "Google", "LoginWithAmazon", "SignInWithApple"], v.provider_type)
    ])
    error_message = "provider_type must be one of: OIDC, SAML, Facebook, Google, LoginWithAmazon, SignInWithApple"
  }
  validation {
    condition = alltrue([
      for k, v in var.identity_providers :
      v.provider_type == "OIDC" ? (
        can(v.provider_details.oidc_issuer) &&
        can(v.provider_details.attributes_url)
      ) : true
    ])
    error_message = "OIDC providers must specify oidc_issuer and attributes_url"
  }
}

variable "clients" {
  description = "Map of Cognito user pool clients configuration"
  type = map(object({
    name                                 = string
    generate_secret                      = optional(bool)
    allowed_oauth_flows                  = optional(list(string))
    allowed_oauth_flows_user_pool_client = optional(bool)
    allowed_oauth_scopes                 = optional(list(string))
    callback_urls                        = optional(list(string))
    logout_urls                          = optional(list(string))
    supported_identity_providers         = optional(list(string))
    refresh_token_validity               = optional(number)
    access_token_validity                = optional(number)
    id_token_validity                    = optional(number)
    token_validity_units                 = optional(map(string))
    enable_token_revocation              = optional(bool)
    prevent_user_existence_errors        = optional(string)
    explicit_auth_flows                  = optional(list(string))
  }))
  default = {}
}

variable "domains" {
  description = "Map of Cognito user pool domain configuration"
  type = map(object({
    domain_name     = string
    certificate_arn = optional(string)
  }))
  default = {}
}

variable "create_identity_pool" {
  description = "Whether to create a Cognito identity pool"
  type        = bool
  default     = false
}

variable "identity_pool_config" {
  description = "Configuration for the Cognito identity pool"
  type = object({
    allow_unauthenticated_identities = optional(bool)
    server_side_token_check          = optional(bool)
  })
  default = null
}

variable "identity_pool_roles" {
  description = "IAM roles configuration for the Cognito identity pool"
  type = object({
    authenticated_role_arn   = string
    unauthenticated_role_arn = optional(string)
  })
  default = null
}

variable "identity_pool_name" {
  description = "Name of the Cognito identity pool"
  type        = string
  default     = null
}
