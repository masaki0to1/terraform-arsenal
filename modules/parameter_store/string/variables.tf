variable "string_params" {
  description = "List of string parameters to store in Parameter Store"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "param_name_prefix" {
  type        = string
  description = "Prefix to prepend to parameter names in Parameter Store"
}