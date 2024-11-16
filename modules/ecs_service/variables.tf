variable "service_name" {
  type        = string
  description = "The name of the ECS service"
}

variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "task_definition" {
  type        = string
  description = "The task definition to run in the service"
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running"
}

variable "launch_type" {
  type        = string
  description = "The launch type on which to run your service. Valid values are EC2 and FARGATE"
}

variable "platform_version" {
  type        = string
  description = "The platform version on which to run your service"
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "The period (in seconds) during which health check failures are ignored. Only applicable when using a load balancer"
  default     = null
}

variable "deployment_maximum_percent" {
  type        = number
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  default     = null
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  default     = null
}

variable "enable_ecs_managed_tags" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
}

variable "propagate_tags" {
  type        = string
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks"
}

variable "subnets" {
  type        = list(string)
  description = "The subnets associated with the task or service"
}

variable "security_groups" {
  type        = list(string)
  description = "The security groups associated with the task or service"
}

variable "assign_public_ip" {
  type        = bool
  description = "Specifies whether to assign a public IP address to the Elastic Network Interface (ENI) of the ECS task. Applies when using FARGATE launch type."
  default     = null
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the Load Balancer target group to associate with the service"
  default     = null
}

variable "container_name" {
  type        = string
  description = "The name of the container to associate with the load balancer"
  default     = null
}

variable "container_port" {
  type        = number
  description = "The port on the container to associate with the load balancer"
  default     = null
}
