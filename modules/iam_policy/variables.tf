variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "policy_statements" {
  description = "Statements of the IAM policy"
  type = list(object({
    sid       = optional(string)
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
}

variable "role_id" {
  description = "ID of the IAM role"
  type        = string
}

variable "ecr_repo_arn" {
  description = "ARN of the ECR repository"
  type        = string
  default     = null
}
