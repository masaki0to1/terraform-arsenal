variable "topic_name" {
  description = "Name of SNS topic"
  type        = string
}

variable "protocol" {
  description = "Protocol for SNS subscription"
  type        = string
}

variable "endpoint" {
  description = "Endpoint for SNS subscription"
  type        = string
}
