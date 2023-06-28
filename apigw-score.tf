resource "aws_api_gateway_rest_api" "score" {
  name        = "score"
  description = "API for GET /score"
}

resource "aws_api_gateway_resource" "score" {
  parent_id   = aws_api_gateway_rest_api.score.root_resource_id
  path_part   = "score"
  rest_api_id = aws_api_gateway_rest_api.score.id
}

resource "aws_api_gateway_method" "score" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.score.id
  rest_api_id   = aws_api_gateway_rest_api.score.id
}

resource "aws_api_gateway_method_response" "score_response_200" {
  http_method = aws_api_gateway_method.score.http_method
  resource_id = aws_api_gateway_resource.score.id
  rest_api_id = aws_api_gateway_rest_api.score.id
  status_code = "200"
}

resource "aws_api_gateway_integration" "score" {
  http_method             = aws_api_gateway_method.score.http_method
  resource_id             = aws_api_gateway_resource.score.id
  rest_api_id             = aws_api_gateway_rest_api.score.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.score_lambda.invoke_arn
}

#       The configuration below will satisfy ordering considerations,
#       but not pick up all future REST API changes. More advanced patterns
#       are possible, such as using the filesha1() function against the
#       Terraform configuration file(s) or removing the .id references to
#       calculate a hash against whole resources. But using whole
#       resources will show a difference after the initial implementation.
#       It will stabilize to only change when resources change afterwards.

resource "aws_api_gateway_deployment" "score" {
  rest_api_id = aws_api_gateway_rest_api.score.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.score.id,
      aws_api_gateway_method.score.id,
      aws_api_gateway_integration.score.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "score" {
  deployment_id = aws_api_gateway_deployment.score.id
  rest_api_id   = aws_api_gateway_rest_api.score.id
  stage_name    = "dev"
}

resource "aws_api_gateway_model" "score" {
  content_type = "application/json"
  name         = "score"
  rest_api_id  = aws_api_gateway_rest_api.score.id
  description  = "a JSON schema"
  schema = jsonencode({
    type = "object"
  })
}

resource "aws_api_gateway_request_validator" "score" {
  name                        = "scoreAPIRequestValidator"
  rest_api_id                 = aws_api_gateway_rest_api.score.id
  validate_request_body       = true
  validate_request_parameters = true
}