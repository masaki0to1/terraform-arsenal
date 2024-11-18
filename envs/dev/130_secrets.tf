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
  is_basic_auth_pass        = false
  aws_profile               = local.aws_default_profile
  env                       = local.env
  secret_name               = "dbpass"
  plain_secret              = var.dbpass
  kms_key_alias             = module.dbpass_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_dbpass"
}

module "secret_authpass_redash" {
  source                    = "../../modules/secrets"
  is_basic_auth_pass        = true
  aws_profile               = local.aws_default_profile
  env                       = local.env
  secret_name               = "authpass_redash"
  plain_secret              = var.authpass_redash
  kms_key_alias             = module.authpass_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_authpass_redash"
  auth_user                 = var.authuser_redash
}

module "secret_authpass_admin" {
  source                    = "../../modules/secrets"
  is_basic_auth_pass        = true
  aws_profile               = local.aws_default_profile
  env                       = local.env
  secret_name               = "authpass_admin"
  plain_secret              = var.authpass_admin
  kms_key_alias             = module.authpass_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_authpass_admin"
  auth_user                 = var.authuser_admin
}

module "secret_line_client_secret" {
  source                    = "../../modules/secrets"
  is_basic_auth_pass        = false
  aws_profile               = local.aws_default_profile
  env                       = local.env
  secret_name               = "line_client_secret"
  plain_secret              = var.line_client_secret
  kms_key_alias             = module.secrets_enc_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_line_client_secret"
}

module "secret_line_api_key" {
  source                    = "../../modules/secrets"
  is_basic_auth_pass        = false
  aws_profile               = local.aws_default_profile
  env                       = local.env
  secret_name               = "line_api_key"
  plain_secret              = var.line_api_key
  kms_key_alias             = module.secrets_enc_key.attrs
  password_change_indicator = local.password_change_indicator
  keep_count                = 3
  cred_dir                  = "${path.module}/../credentials/"
  cred_file                 = ".decrypted_line_api_key"
}