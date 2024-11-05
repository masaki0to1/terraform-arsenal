resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role            = var.lambda_role_arn
  architectures = var.architectures
  handler         = var.handler
  runtime         = var.runtime
  filename        = var.filename
  source_code_hash = filebase64sha256(var.filename)
  
  memory_size     = var.memory_size
  timeout         = var.timeout

  environment {
    variables = {
      for key, value in var.envs : key => value
    }
  }
}