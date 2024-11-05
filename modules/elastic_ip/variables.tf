variable "instance_id" {
  description = "The ID of the instance to associate the Elastic IP with"
  type        = string
  default     = null
}

variable "domain" {
  description = "The domain of the Elastic IP"
  type        = string
  default     = "vpc"
}