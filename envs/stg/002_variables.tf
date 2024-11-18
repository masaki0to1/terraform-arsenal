# Define state configuration to match the backend configuration in common/main.tfbackend
variable "common_conf_state" {
  description = "Variables about Terraform state backend for Common Configurations"
  type = object({
    region      = string
    bucket      = string
    key         = string
    aws_profile = string
  })
  default = {
    region      = "ap-northeast-1"
    bucket      = "tf-state-282208395586"
    key         = "common/main.tfstate"
    aws_profile = "tf-user@Sandbox"
  }
}

variable "aws_profile" {
  description = "AWS Profile for stg"
  type        = string
  default     = "tf-user@Sandbox"
}

variable "github_repo" {
  description = "The github repository to use"
  type        = string
}

variable "domain" {
  description = "project domain"
  type        = string
}

# variable "user_pool_domain" {
#   description = "userpool domain"
#   type        = string
#   default     = null
# }

variable "line_client_id" {
  description = "LINE Login Channel ID"
  type        = string
  sensitive   = true
}

variable "dbpass" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "authpass_redash" {
  description = "Basic authentication password for Redash"
  type        = string
  sensitive   = true
}

variable "authpass_admin" {
  description = "Basic authentication password for admin"
  type        = string
  sensitive   = true
}

variable "authuser_redash" {
  description = "Basic authentication username for redash"
  type        = string
  sensitive   = true
  default     = "redash_testuser"
}

variable "authuser_admin" {
  description = "Basic authentication username for admin"
  type        = string
  sensitive   = true
  default     = "lp_admin_testuser"
}

variable "line_api_key" {
  description = "LINE API key"
  type        = string
  sensitive   = true
}

variable "line_client_secret" {
  description = "LINE Login Channel Secret"
  type        = string
  sensitive   = true
}
