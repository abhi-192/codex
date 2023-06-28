data "aws_iam_policy_document" "worker_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_worker_lambda" {
  assume_role_policy = data.aws_iam_policy_document.worker_assume_role.json
  name               = "iam_for_worker_lambda"
}

resource "aws_iam_role_policy_attachment" "worker_lambda_policy" {
  for_each = tomap({
    "one" = aws_iam_policy.worker-lambda-policy.arn,
    "two" = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  })

  role       = aws_iam_role.iam_for_worker_lambda.name
  policy_arn = each.value
}

data "archive_file" "worker_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/worker-lambda.js"
  output_path = "${path.module}/lambda/worker-lambda.zip"
}

resource "aws_lambda_function" "worker_lambda" {
  filename         = "${path.module}/lambda/worker-lambda.zip"
  function_name    = "lambda_worker"
  role             = aws_iam_role.iam_for_worker_lambda.arn
  handler          = "worker-lambda.handler"
  source_code_hash = data.archive_file.worker_lambda.output_base64sha256
  runtime          = "nodejs16.x"
}