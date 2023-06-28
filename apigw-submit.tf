resource "aws_api_gateway_rest_api" "submit" {
  name        = "submit"
  description = "API for POST /submit"
}

resource "aws_api_gateway_resource" "submit" {
  parent_id   = aws_api_gateway_rest_api.submit.root_resource_id
  path_part   = "submit"
  rest_api_id = aws_api_gateway_rest_api.submit.id
}

resource "aws_api_gateway_method" "submit" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.submit.id
  rest_api_id   = aws_api_gateway_rest_api.submit.id
}

resource "aws_api_gateway_method_response" "submit_response_200" {
  http_method = aws_api_gateway_method.submit.http_method
  resource_id = aws_api_gateway_resource.submit.id
  rest_api_id = aws_api_gateway_rest_api.submit.id
  status_code = "200"
}

resource "aws_api_gateway_integration" "submit" {
  http_method             = aws_api_gateway_method.submit.http_method
  resource_id             = aws_api_gateway_resource.submit.id
  rest_api_id             = aws_api_gateway_rest_api.submit.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.submit_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "submit" {
  rest_api_id = aws_api_gateway_rest_api.submit.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.submit.id,
      aws_api_gateway_method.submit.id,
      aws_api_gateway_integration.submit.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "submit" {
  deployment_id = aws_api_gateway_deployment.submit.id
  rest_api_id   = aws_api_gateway_rest_api.submit.id
  stage_name    = "dev"
}

resource "aws_api_gateway_model" "submit" {
  content_type = "application/json"
  name         = "submit"
  rest_api_id  = aws_api_gateway_rest_api.submit.id
  description  = "a JSON schema"
  schema = jsonencode({
    type = "object"
  })
}

resource "aws_api_gateway_request_validator" "submit" {
  name                        = "submitAPIRequestValidator"
  rest_api_id                 = aws_api_gateway_rest_api.submit.id
  validate_request_body       = true
  validate_request_parameters = true
}