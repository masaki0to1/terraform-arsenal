variable "eip_id" {
  description = "The Elastic IP address ID to attach the NAT gateway to"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to attach the NAT gateway to"
  type        = string
}