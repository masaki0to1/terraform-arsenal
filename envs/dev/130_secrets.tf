locals {
  password_change_indicator = join(",", [
    "dbpass: Changed to ${var.dbpass}\n", # Will be displayed as: dbpass: Changed to ********
    "authpass_redash: Changed to ${var.authpass_redash}\n",
    "authpass_admin: Changed to ${var.authpass_redash}\n",
    "line_client_secret: Changed to ${var.line_client_secret}\n",
    "line_api_key: Changed to ${var.line_api_key}\n"
  ])
}

module "secret_dbpass" {
  source                    = "../../modules/secrets"
  aws_profile               = local.aws_profile
  env                       = local.env
  prefix                    = "dbpass"
  plain_text                = var.dbpass
  kms_key_alias             = module.dbpass_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_dbpass"
  is_basic_auth_pass        = false
}

module "secret_authpass_redash" {
  source                    = "../../modules/secrets"
  aws_profile               = local.aws_profile
  env                       = local.env
  prefix                    = "authpass_redash"
  plain_text                = var.authpass_redash
  kms_key_alias             = module.authpass_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_authpass_redash"
  is_basic_auth_pass        = true
  auth_user                 = "redash_user"
}

module "secret_authpass_admin" {
  source                    = "../../modules/secrets"
  aws_profile               = local.aws_profile
  env                       = local.env
  prefix                    = "authpass_admin"
  plain_text                = var.authpass_admin
  kms_key_alias             = module.authpass_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_authpass_admin"
  is_basic_auth_pass        = true
  auth_user                 = var.user_admin
}

module "secret_line_client_secret" {
  source                    = "../../modules/secrets"
  aws_profile               = local.aws_profile
  env                       = local.env
  prefix                    = "line_client_secret"
  plain_text                = var.line_client_secret
  kms_key_alias             = module.secrets_enc_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_line_client_secret"
  is_basic_auth_pass        = false
}

module "secret_line_api_key" {
  source                    = "../../modules/secrets"
  aws_profile               = local.aws_profile
  env                       = local.env
  prefix                    = "line_api_key"
  plain_text                = var.line_api_key
  kms_key_alias             = module.secrets_enc_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_line_api_key"
  is_basic_auth_pass        = false
}