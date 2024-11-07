variable "param_name_prefix" {
  description = "Prefix for the parameter name"
  type        = string
}

variable "secure_param_name" {
  description = "Name of the secure parameter"
  type        = string
}

variable "secure_param_value" {
  description = "Value of the secure parameter" 
  type        = string
  sensitive   = true
}
