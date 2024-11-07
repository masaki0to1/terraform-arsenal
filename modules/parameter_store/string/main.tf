resource "aws_ssm_parameter" "this" {
  for_each = {
    for string_param in var.string_params : string_param.name => string_param.value 
  }
  type = "String"
  name = "${var.param_name_prefix}${each.key}"
  value = each.value
}