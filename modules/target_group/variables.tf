variable "name" {
  type        = string
  description = "Name of the target group"
}

variable "port" {
  type        = number
  description = "Port on which targets receive traffic"
}

variable "protocol" {
  type        = string
  description = "Protocol to use for routing traffic to the targets"
  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "TCP_UDP", "TLS", "UDP"], var.protocol)
    error_message = "Protocol must be one of: HTTP, HTTPS, TCP, TCP_UDP, TLS, UDP"
  }
}

variable "target_type" {
  type        = string
  description = "Type of target that you must specify when registering targets with this target group"
  validation {
    condition     = contains(["instance", "ip", "lambda", "alb"], var.target_type)
    error_message = "Target type must be one of: instance, ip, lambda, alb"
  }
}

variable "vpc_id" {
  type        = string
  description = "Identifier of the VPC in which to create the target group"
}

variable "path" {
  type        = string
  description = "Health check path for the targets"
  default     = "/"
}

variable "healthy_threshold" {
  type        = number
  description = "Number of consecutive health check successes required before considering a target healthy"
  validation {
    condition     = var.healthy_threshold >= 2 && var.healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10"
  }
}

variable "unhealthy_threshold" {
  type        = number
  description = "Number of consecutive health check failures required before considering a target unhealthy"
  validation {
    condition     = var.unhealthy_threshold >= 2 && var.unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10"
  }
}

variable "target_group_conf" {
  type = object({
    timeout  = number
    interval = number
    matcher  = string
  })
  description = "Configuration for target group health check settings"

  validation {
    condition     = var.target_group_conf.timeout >= 2 && var.target_group_conf.timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds"
  }

  validation {
    condition     = var.target_group_conf.interval >= 5 && var.target_group_conf.interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds"
  }
}