variable "github_repo" {
  description = "The github repository to use"
  type        = string
}

variable "domain" {
  description = "project domain"
  type        = string
}

variable "user_pool_domain" {
  description = "userpool domain"
  type        = string
  default     = null
}

variable "line_client_id" {
  description = "LINE Login Channel ID"
  type        = string
  sensitive   = true
  default     = null
}

variable "dbpass" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = null
}

variable "authpass_redash" {
  description = "Basic authentication password for Redash"
  type        = string
  sensitive   = true
  default     = null
}

variable "authpass_admin" {
  description = "Basic authentication password for admin"
  type        = string
  sensitive   = true
  default     = null
}

variable "user_admin" {
  description = "Basic authentication username for admin"
  type        = string
  sensitive   = false
  default     = "lp_admin_user"
}

variable "line_api_key" {
  description = "LINE API key"
  type        = string
  sensitive   = true
  default     = null
}

variable "line_client_secret" {
  description = "LINE Login Channel Secret"
  type        = string
  sensitive   = true
  default     = null
}
