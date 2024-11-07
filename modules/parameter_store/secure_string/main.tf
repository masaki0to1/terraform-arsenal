resource "aws_ssm_parameter" "this" {
  type = "SecureString"
  name = "${var.param_name_prefix}${var.secure_param_name}"
  value = var.secure_param_value
}