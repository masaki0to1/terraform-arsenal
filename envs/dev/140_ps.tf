module "string_params" {
  source            = "../../modules/parameter_store/string"
  param_name_prefix = "/${local.name_prefix}/"
  string_params = [
    {
      name  = "github_repo"
      value = var.github_repo
    },
    {
      name  = "domain"
      value = var.domain
    },
    {
      name  = "user_pool_domain"
      value = var.user_pool_domain
    },
    {
      name  = "line_client_id"
      value = var.line_client_id
    },
    {
      name  = "user_admin"
      value = var.user_admin
    }
  ]
}

module "secure_string_param_dbpass" {
  source             = "../../modules/parameter_store/secure_string"
  param_name_prefix  = "/${local.name_prefix}/"
  secure_param_name  = module.secret_dbpass.attrs.prefix
  secure_param_value = module.secret_dbpass.attrs.decrypted_secret
}

module "secure_string_params_redash" {
  source             = "../../modules/parameter_store/secure_string"
  param_name_prefix  = "/${local.name_prefix}/"
  secure_param_name  = module.secret_authpass_redash.attrs.prefix
  secure_param_value = module.secret_authpass_redash.attrs.decrypted_secret
}

module "secure_string_params_admin" {
  source             = "../../modules/parameter_store/secure_string"
  param_name_prefix  = "/${local.name_prefix}/"
  secure_param_name  = module.secret_authpass_admin.attrs.prefix
  secure_param_value = module.secret_authpass_admin.attrs.decrypted_secret
}

module "secure_string_params_line_api" {
  source             = "../../modules/parameter_store/secure_string"
  param_name_prefix  = "/${local.name_prefix}/"
  secure_param_name  = module.secret_line_api_key.attrs.prefix
  secure_param_value = module.secret_line_api_key.attrs.decrypted_secret
}

module "secure_string_params_line_secret" {
  source             = "../../modules/parameter_store/secure_string"
  param_name_prefix  = "/${local.name_prefix}/"
  secure_param_name  = module.secret_line_client_secret.attrs.prefix
  secure_param_value = module.secret_line_client_secret.attrs.decrypted_secret
}
