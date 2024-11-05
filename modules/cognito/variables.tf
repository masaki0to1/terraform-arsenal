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

// Identity Provider variables
variable "provider_name" {
  type        = string
  description = "Name of the identity provider"
}

variable "provider_type" {
  type        = string
  description = "Type of the identity provider (e.g., OIDC, SAML)"
}

variable "client_id" {
  description = "Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Client Secret"
  type        = string
  sensitive   = true #
}

variable "provider_details" {
  type = object({
    authorize_scopes              = string
    attributes_request_method     = string
    authorize_url                 = string
    attributes_url_add_attributes = optional(string)
    token_url                     = string
    attributes_url                = string
    jwks_uri                      = string
    oidc_issuer                   = string
  })
  description = "Configuration details for the identity provider"
}

variable "attribute_mapping" {
  type = object({
    email    = string
    username = string
    name     = string
  })
  description = "Mapping of provider attributes to Cognito attributes"
}

variable "idp_identifiers" {
  type        = list(string)
  description = "List of identity provider identifiers"
  default     = []
}

// User Pool Client variables
variable "client_name" {
  type        = string
  description = "Name of the Cognito user pool client"
}

variable "generate_secret" {
  type        = bool
  description = "Whether to generate a client secret"
  default     = false
}

variable "allowed_oauth_flows" {
  type        = list(string)
  description = "List of allowed OAuth flows (e.g., code, implicit)"
  default     = []
}

variable "allowed_oauth_flows_user_pool_client" {
  type        = bool
  description = "Whether to allow OAuth flows for the client"
  default     = true
}

variable "allowed_oauth_scopes" {
  type        = list(string)
  description = "List of allowed OAuth scopes"
  default     = []
}

variable "callback_urls" {
  type        = list(string)
  description = "List of allowed callback URLs"
  default     = []
}

variable "logout_urls" {
  type        = list(string)
  description = "List of allowed logout URLs"
  default     = []
}

variable "enable_token_revocation" {
  type        = bool
  description = "Whether to enable token revocation"
  default     = true
}

variable "prevent_user_existence_errors" {
  type        = string
  description = "Choose which errors and responses are returned when the user does not exist"
  default     = "ENABLED"
}

variable "explicit_auth_flows" {
  type        = list(string)
  description = "List of explicit authentication flows"
  default     = []
}

variable "refresh_token_validity" {
  type        = number
  description = "Time limit in days for refresh token validity"
  default     = 30
}

variable "access_token_validity" {
  type        = number
  description = "Time limit in hours for access token validity"
  default     = 1
}

variable "id_token_validity" {
  type        = number
  description = "Time limit in hours for ID token validity"
  default     = 1
}

variable "token_validity_units" {
  type = object({
    access_token  = string
    id_token      = string
    refresh_token = string
  })
  description = "Units for token validity (e.g., hours, days)"
  default = {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

variable "domain_name" {
  type        = string
  description = "Domain name for the Cognito user pool"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for the domain"
}

variable "identity_pool_name" {
  type        = string
  description = "Name of the Cognito identity pool"
}

variable "allow_unauthenticated_identities" {
  type        = bool
  description = "Whether to allow unauthenticated identities"
  default     = false
}

variable "server_side_token_check" {
  type        = bool
  description = "Whether to enable server-side token validation"
  default     = false
}

variable "authenticated_role_arn" {
  type        = string
  description = "ARN of the IAM role for authenticated users"
}

variable "unauthenticated_role_arn" {
  type        = string
  description = "ARN of the IAM role for unauthenticated users"
  default     = null
}
