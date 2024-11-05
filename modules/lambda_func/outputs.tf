output "attrs" {
  value = {
    function_name = aws_lambda_function.this.function_name
    arn           = aws_lambda_function.this.arn
    invoke_arn    = aws_lambda_function.this.invoke_arn
  }
}