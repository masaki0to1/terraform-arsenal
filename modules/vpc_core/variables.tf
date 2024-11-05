variable "env" {
  description = "Environment name (prod, stg, or dev)"
  type        = string
}

variable "vpc_conf" {
  description = "map for vpc config"
  type = object({
    name                 = string
    cidr_block           = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
    instance_tenancy     = string
  })
}

variable "private_subnets" {
  description = "map for private subnets"
  type = map(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "public_subnets" {
  description = "map for public subnets"
  type = map(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "map_public_ip_on_launch" {
  description = "Enable or disable the 'map public IP on launch' attribute"
  type        = bool
}