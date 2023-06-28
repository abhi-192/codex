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