variable "vpc_id" {
  type = string
}

variable "route_table_name" {
  type = string
}

variable "tags" {
  description = "Additional tags for the route table"
  type        = map(string)
  default     = {}
}

variable "routes" {
  type = map(object({
    destination_cidr_block    = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    network_interface_id      = optional(string)
    vpc_peering_connection_id = optional(string)
    transit_gateway_id        = optional(string)
  }))
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate with the route table"
}