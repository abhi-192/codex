data "aws_iam_policy_document" "score_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_score_lambda" {
  assume_role_policy = data.aws_iam_policy_document.score_assume_role.json
  name               = "iam_for_score_lambda"
}

resource "aws_iam_role_policy_attachment" "score_lambda_policy" {
  role       = aws_iam_role.iam_for_score_lambda.name
  policy_arn = aws_iam_policy.score-lambda-policy.arn
}

data "archive_file" "score_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/score-lambda.js"
  output_path = "${path.module}/lambda/score-lambda.zip"
}

resource "aws_lambda_function" "score_lambda" {
  filename         = "${path.module}/lambda/score-lambda.zip"
  function_name    = "lambda_score"
  role             = aws_iam_role.iam_for_score_lambda.arn
  handler          = "score-lambda.handler"
  source_code_hash = data.archive_file.score_lambda.output_base64sha256
  runtime          = "nodejs16.x"
}

# permission to access lambda function from API gateway

resource "aws_lambda_permission" "score_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.score_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowScoreAPIInvoke"
  source_arn    = "${aws_api_gateway_rest_api.score.execution_arn}/*"
}
