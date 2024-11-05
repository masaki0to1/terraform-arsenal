variable "name" {
  type        = string
  description = "Name of the ALB"
}

variable "alb_conf" {
  type = object({
    internal                   = bool
    enable_deletion_protection = bool
    load_balancer_type         = string
  })
  description = "Configuration for the ALB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the ALB will be placed. For high availability, specify at least two subnets in different AZs."
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnets in different AZs are required for high availability."
  }
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach to the ALB"
}
