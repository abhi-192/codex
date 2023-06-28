resource "aws_api_gateway_rest_api" "submission" {
  name        = "submission"
  description = "API for GET /submission and /submissions/:id"
}

resource "aws_api_gateway_resource" "submission" {
  parent_id   = aws_api_gateway_rest_api.submission.root_resource_id
  path_part   = "submission"
  rest_api_id = aws_api_gateway_rest_api.submission.id
}

resource "aws_api_gateway_method" "submission" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.submission.id
  rest_api_id   = aws_api_gateway_rest_api.submission.id
}

resource "aws_api_gateway_method_response" "submission_response_200" {
  http_method = aws_api_gateway_method.submission.http_method
  resource_id = aws_api_gateway_resource.submission.id
  rest_api_id = aws_api_gateway_rest_api.submission.id
  status_code = "200"
}

resource "aws_api_gateway_integration" "submission" {
  http_method             = aws_api_gateway_method.submission.http_method
  resource_id             = aws_api_gateway_resource.submission.id
  rest_api_id             = aws_api_gateway_rest_api.submission.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.submission_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "submission" {
  rest_api_id = aws_api_gateway_rest_api.submission.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.submission.id,
      aws_api_gateway_method.submission.id,
      aws_api_gateway_integration.submission.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "submission" {
  deployment_id = aws_api_gateway_deployment.submission.id
  rest_api_id   = aws_api_gateway_rest_api.submission.id
  stage_name    = "dev"
}

resource "aws_api_gateway_model" "submission" {
  content_type = "application/json"
  name         = "submission"
  rest_api_id  = aws_api_gateway_rest_api.submission.id
  description  = "a JSON schema"
  schema = jsonencode({
    type = "object"
  })
}

resource "aws_api_gateway_request_validator" "submission" {
  name                        = "submissionAPIRequestValidator"
  rest_api_id                 = aws_api_gateway_rest_api.submission.id
  validate_request_body       = true
  validate_request_parameters = true
}