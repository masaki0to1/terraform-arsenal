variable "log_group_name" {
  type        = string
  description = "The name of the CloudWatch log group"
}

variable "retention_in_days" {
  type        = number
  description = "The number of days to retain log events in the log group"
}
