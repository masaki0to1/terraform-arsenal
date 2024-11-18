variable "is_basic_auth_pass" {
  type        = string
  description = "Whether this is a password for Basic Authentication"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile name to use for KMS encryption/decryption"
}

variable "env" {
  type        = string
  description = "Environment name (e.g. dev, stg, prod) used for credential file path"
}

variable "secret_name" {
  type        = string
  description = "Secret name"
}

variable "plain_secret" {
  type        = string
  description = "Direct input of secret value to be encrypted"
  default     = ""
}

variable "kms_key_alias" {
  description = "KMS key alias ARN used for encryption"
}

variable "password_change_indicator" {
  type        = string
  description = "Value that triggers password change when modified"
}

variable "keep_count" {
  type        = number
  description = "Number of encrypted files to keep (older files will be deleted)"
  default     = 3
}

variable "cred_dir" {
  type        = string
  description = "Directory path for credential files"
}

variable "cred_file" {
  type        = string
  description = "Credential file name"
}

variable "auth_user" {
  type        = string
  description = "User name for Basic Authentication"
  default     = null
}
