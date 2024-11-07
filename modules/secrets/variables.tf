variable "aws_profile" {
  type        = string
  description = "AWS profile name to use for KMS encryption/decryption"
}

variable "env" {
  type        = string
  description = "Environment name (e.g. dev, stg, prod) used for credential file path"
}

variable "prefix" {
  type        = string
  description = "Prefix for encrypted/decrypted file names"
}

variable "plain_text" {
  type        = string
  default     = ""
  description = "Plain text to be encrypted. If empty, decryption will be performed"
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
  default     = 3
  description = "Number of encrypted files to keep (older files will be deleted)"
}

variable "cred_dir" {
  type        = string
  description = "Directory path for credential files"
}

variable "cred_file" {
  type        = string
  description = "Credential file name"
}

variable "is_basic_auth_pass" {
  type        = string
  description = "Whether this is a password for Basic Authentication"
}

variable "auth_user" {
  description = "User name for Basic Authentication"
  type        = string
  default     = null
}