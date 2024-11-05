output "apigwv2_http_api" {
  value = {
    id            = aws_apigatewayv2_api.http_api.id
    name          = aws_apigatewayv2_api.http_api.name
    arn           = aws_apigatewayv2_api.http_api.arn
    execution_arn = aws_apigatewayv2_api.http_api.execution_arn
  }
}

output "apigwv2_stage_default" {
  value = {
    id   = aws_apigatewayv2_stage.default.id
    name = aws_apigatewayv2_stage.default.name
  }
}