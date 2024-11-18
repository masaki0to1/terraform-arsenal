output "attrs" {
  value = {
    secret_name      = var.secret_name
    decrypted_secret = local.decrypted_secret
  }
  sensitive = true
}

output "auth_user_pass_map" {
  value = var.is_basic_auth_pass ? {
    (var.auth_user) = local.decrypted_secret
  } : null
  sensitive = true
}