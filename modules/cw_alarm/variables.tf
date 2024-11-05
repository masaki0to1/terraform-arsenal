variable "name" {
  description = "The name of the CloudWatch Log Metric Filter"
  type        = string
}

variable "pattern" {
  description = "The pattern to search for in the log group"
  type        = string
}

variable "log_group_name" {
  description = "The name of the CloudWatch Log Group to search"
  type        = string
}

variable "metric_transformation" {
  description = "The metric transformation configuration for the CloudWatch Log Metric Filter"
  type = object({
    name          = string
    namespace     = string
    value         = string
    default_value = optional(number)
  })
}

variable "alarm_name" {
  description = "The name of the CloudWatch alarm"
  type        = string
}

variable "alarm_description" {
  description = "The description for the CloudWatch alarm"
  type        = string
  default     = null
}

variable "comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified statistic and threshold"
  type        = string
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = number
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = number
}

variable "statistic" {
  description = "The statistic to apply to the alarm's associated metric"
  type        = string
}

variable "threshold" {
  description = "The value against which the specified statistic is compared"
  type        = number
}

variable "treat_missing_data" {
  description = "How to treat missing data when evaluating the alarm"
  type        = string
  default     = "missing"
}

variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "The list of actions to execute when this alarm transitions into an OK state"
  type        = list(string)
  default     = []
}

variable "dimensions" {
  description = "The dimensions for the alarm's associated metric"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the alarm"
  type        = map(string)
  default     = {}
}
