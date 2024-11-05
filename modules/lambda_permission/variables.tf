variable "function_name" {
  description = "Name of the Lambda function to grant permission to"
  type        = string
}

variable "statement_id" {
  description = "Unique identifier for the Lambda permission statement"
  type        = string
}

variable "principal" {
  description = "AWS service or account that is allowed to invoke the Lambda function"
  type        = string
}

variable "source_arn" {
  description = "ARN of the source service/resource that will invoke the Lambda function"
  type        = string
}
