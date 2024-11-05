variable "load_balancer_arn" {
  description = "ARN of the load balancer"
  type        = string
}

variable "port" {
  description = "Port on which the load balancer is listening"
  type        = number
}

variable "protocol" {
  description = "Protocol for connections from clients to the load balancer"
  type        = string
}

variable "default_action" {
  description = "Default action for the listener"
  type = object({
    type             = string
    target_group_arn = optional(string)

    fixed_response = optional(object({
      content_type = string
      message_body = string
      status_code  = string
    }))

    redirect = optional(object({
      protocol    = optional(string)
      port        = optional(string)
      status_code = string
      host        = optional(string)
      path        = optional(string)
      query       = optional(string)
    }))
  })
}

variable "rules" {
  description = "List of rules for the listener"
  type = list(object({
    action = object({
      type             = string
      target_group_arn = optional(string)

      fixed_response = optional(object({
        content_type = string
        message_body = string
        status_code  = string
      }))

      redirect = optional(object({
        protocol    = optional(string)
        port        = optional(string)
        host        = optional(string)
        path        = optional(string)
        query       = optional(string)
        status_code = string
      }))
    })

    conditions = list(object({
      path_pattern = optional(list(string))
      host_header  = optional(list(string))
    }))
  }))
  default = []
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listeners"
  type        = string
  default     = null
}