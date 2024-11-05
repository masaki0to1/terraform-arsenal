variable "role_name" {
  description = "IAM Role name that attach policy"
  type        = string
}

variable "policy_arns" {
  description = "IAM Policy ARNs that attach to IAM Role"
  type        = list(string)
  default     = []
}