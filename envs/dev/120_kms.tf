module "dbpass_key" {
  source                      = "../../modules/kms"
  key_description             = "KMS key used to encrypt DB Password."
  key_alias_name              = "alias/${local.name_prefix}-dbpass-key"
  key_deletion_window_in_days = "30"
  is_key_enabled              = true
  enable_key_rotation         = true
  key_usage                   = "ENCRYPT_DECRYPT"
  customer_master_key_spec    = "SYMMETRIC_DEFAULT"
}

module "authpass_key" {
  source                      = "../../modules/kms"
  key_description             = "KMS key used to encrypt BasicAuth Password."
  key_alias_name              = "alias/${local.name_prefix}-authpass-key"
  key_deletion_window_in_days = "30"
  is_key_enabled              = true
  enable_key_rotation         = true
  key_usage                   = "ENCRYPT_DECRYPT"
  customer_master_key_spec    = "SYMMETRIC_DEFAULT"
}

module "secrets_enc_key" {
  source                      = "../../modules/kms"
  key_description             = "KMS key used to encrypt sensitive data including API Keys, Signatures, Public Keys, and other confidential information."
  key_alias_name              = "alias/${local.name_prefix}-secrets-enc-key"
  key_deletion_window_in_days = "30"
  is_key_enabled              = true
  enable_key_rotation         = true
  key_usage                   = "ENCRYPT_DECRYPT"
  customer_master_key_spec    = "SYMMETRIC_DEFAULT"
}
