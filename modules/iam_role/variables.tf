variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_statements" {
  description = "AssumeRolePolicy statements"
  type = list(object({
    Effect    = string
    Action    = string
    Principal = map(any)
    Condition = optional(map(map(string)), {})
  }))
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(string)
  default     = {}
}
