variable "family" {
  type        = string
  description = "Family name for the task definition"
}

variable "requires_compatibilities" {
  type        = list(string)
  description = "Task definition compatibility requirements (EC2, FARGATE, etc.)"
}

variable "network_mode" {
  type        = string
  description = "Network mode for the task definition (awsvpc, bridge, host, etc.)"
}

variable "container_definitions" {
  type = list(object({
    name              = string
    image             = string
    cpu               = optional(number)
    memory            = optional(number)
    memoryReservation = optional(number)
    essential         = optional(bool)
    portMappings = optional(list(object({
      containerPort = number
      hostPort      = optional(number)
      protocol      = optional(string)
    })))
    environment = optional(list(object({
      name  = string
      value = string
    })))
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })))
    logConfiguration = optional(object({
      logDriver = string
      options   = map(string)
    }))
  }))
  description = "List of container definitions for the task definition"
}

variable "cpu" {
  type        = string
  description = "CPU units for the task"
  default     = null
}

variable "memory" {
  type        = string
  description = "Memory (in MB) for the task"
  default     = null
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of the task execution role"
  default     = null
}

variable "task_role_arn" {
  type        = string
  description = "ARN of the task role"
  default     = null
}
