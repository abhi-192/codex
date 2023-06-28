data "aws_iam_policy_document" "evaluate_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "evaluate_lambda_policy_document" {
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

data "aws_iam_policy" "evaluate_lambda_basic_execution_role_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "evaluate_lambda_policy" {
  name_prefix = "lambda_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.evaluate_lambda_policy_document.json
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "iam_for_evaluate_lambda" {
  assume_role_policy = data.aws_iam_policy_document.evaluate_assume_role.json
  name               = "iam_for_evaluate_lambda"
  managed_policy_arns = [
    data.aws_iam_policy.evaluate_lambda_basic_execution_role_policy.arn,
    aws_iam_policy.evaluate_lambda_policy.arn
  ]
}

resource "aws_iam_role_policy_attachment" "evaluate_lambda_policy" {
  for_each = tomap({
    "one" : aws_iam_policy.evaluate-lambda-policy.arn,
    "two" : "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  })

  role       = aws_iam_role.iam_for_evaluate_lambda.name
  policy_arn = each.value
}

data "archive_file" "evaluate_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/evaluate-lambda.js"
  output_path = "${path.module}/lambda/evaluate-lambda.zip"
}

resource "aws_lambda_function" "evaluate_lambda" {
  filename         = "${path.module}/lambda/evaluate-lambda.zip"
  function_name    = "lambda_evaluate"
  role             = aws_iam_role.iam_for_evaluate_lambda.arn
  handler          = "evaluate-lambda.handler"
  source_code_hash = data.archive_file.evaluate_lambda.output_base64sha256
  runtime          = "nodejs16.x"
}
