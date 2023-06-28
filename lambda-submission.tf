data "aws_iam_policy_document" "submission_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_submission_lambda" {
  assume_role_policy = data.aws_iam_policy_document.submission_assume_role.json
  name               = "iam_for_submission_lambda"
}

resource "aws_iam_role_policy_attachment" "submission_lambda_policy" {
  role       = aws_iam_role.iam_for_submission_lambda.name
  policy_arn = aws_iam_policy.submission-lambda-policy.arn
}

data "archive_file" "submission_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/submission-lambda.js"
  output_path = "${path.module}/lambda/submission-lambda.zip"
}

resource "aws_lambda_function" "submission_lambda" {
  filename         = "${path.module}/lambda/submission-lambda.zip"
  function_name    = "lambda_submission"
  role             = aws_iam_role.iam_for_submission_lambda.arn
  handler          = "submission-lambda.handler"
  source_code_hash = data.archive_file.submission_lambda.output_base64sha256
  runtime          = "nodejs16.x"
}

# permission to access lambda function from API gateway

resource "aws_lambda_permission" "submission_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.submission_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowsubmissionAPIInvoke"
  source_arn    = "${aws_api_gateway_rest_api.submission.execution_arn}/*"
}

