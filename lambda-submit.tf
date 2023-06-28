data "aws_iam_policy_document" "submit_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "submit_lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage*"
    ]
    resources = [
      aws_sqs_queue.scoreQ.arn
    ]
  }
}

data "aws_iam_policy" "submit_lambda_basic_execution_role_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "submit_lambda_policy" {
  name_prefix = "lambda_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.submit_lambda_policy_document.json
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "iam_for_submit_lambda" {
  assume_role_policy = data.aws_iam_policy_document.submit_assume_role.json
  name               = "iam_for_submit_lambda"
  managed_policy_arns = [
    data.aws_iam_policy.submit_lambda_basic_execution_role_policy.arn,
    aws_iam_policy.submit_lambda_policy.arn
  ]
}

resource "aws_iam_role_policy_attachment" "submit_lambda_policy" {
  role       = aws_iam_role.iam_for_submit_lambda.name
  policy_arn = aws_iam_policy.evaluate-lambda-policy.arn
}

data "archive_file" "submit_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/submit-lambda.js"
  output_path = "${path.module}/lambda/submit-lambda.zip"
}

resource "aws_lambda_function" "submit_lambda" {
  filename         = "${path.module}/lambda/submit-lambda.zip"
  function_name    = "lambda_submit"
  role             = aws_iam_role.iam_for_submit_lambda.arn
  handler          = "submit-lambda.handler"
  source_code_hash = data.archive_file.submit_lambda.output_base64sha256
  runtime          = "nodejs16.x"
}

