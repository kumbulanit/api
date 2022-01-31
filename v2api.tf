resource "aws_apigatewayv2_api" "example" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}
resource "aws_apigatewayv2_authorizer" "example" {
  api_id           = aws_apigatewayv2_api.example.id
  authorizer_type  = "REQUEST"
  identity_sources = ["$request.header.Authorization"]
  name             = "example-authorizer"
  authorizer_uri = aws_lambda_function.lambda_ingest_function.invoke_arn 

}
resource "aws_apigatewayv2_deployment" "example" {
  api_id      = aws_apigatewayv2_api.example.id
  description = "Example deployment"

 # triggers = {
 #   redeployment = sha1(join(",", tolist[
 #     jsonencode(aws_apigatewayv2_integration.example),
 #     jsonencode(aws_apigatewayv2_route.example),
 #   ])))
#  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_apigatewayv2_integration" "example" {
  api_id           = aws_apigatewayv2_api.example.id
  integration_type = "HTTP_PROXY"

#  connection_type           = "INTERNET"
#  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "Lambda example"
  integration_method        = "GET"
  integration_uri           = aws_lambda_function.lambda_ingest_function.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}
resource "aws_apigatewayv2_integration" "example-intergration" {
  api_id           = aws_apigatewayv2_api.example.id
  integration_type = "HTTP_PROXY"

  integration_method = "ANY"
  integration_uri    = "https://example.com/{proxy}"
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "ANY /example/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}
resource "aws_apigatewayv2_stage" "example" {
  api_id = aws_apigatewayv2_api.example.id
  name   = "trying-stage"
}
