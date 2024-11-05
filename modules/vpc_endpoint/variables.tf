variable "vpc_id" {
  type = string
}

variable "vpc_endpoint_type" {
  type = string
}

variable "service_name" {
  type = string
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

variable "private_dns_enabled" {
  type    = bool
  default = null
}

variable "route_table_ids" {
  type    = list(string)
  default = null
}
