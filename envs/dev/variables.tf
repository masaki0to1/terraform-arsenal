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

variable "line_client_secret" {
  description = "LINE Login Channel Secret"
  type        = string
  sensitive   = true
  default     = null
}