resource "aws_lambda_permission" "this" {
  function_name = var.function_name
  statement_id  = var.statement_id
  action        = "lambda:InvokeFunction"
  principal     = var.principal
  source_arn    = var.source_arn
}