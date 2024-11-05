variable "function_name" {
  description = "Name of Lambda function"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of IAM role for Lambda function"
  type        = string
}

variable "architectures" {
  description = "Instruction set architecture for Lambda function. Valid values are ['x86_64'] and ['arm64']"
  type        = list(string)
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "runtime" {
  description = "Runtime environment for Lambda function"
  type        = string
}

variable "filename" {
  description = "Path to the function's deployment package"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB for the function"
  type        = number
}

variable "timeout" {
  description = "Function execution time limit in seconds"
  type        = number
}

variable "envs" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}
