resource "aws_dynamodb_table" "submission" {
  name           = "submission"
  hash_key       = "submissionID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  attribute {
    name = "submissionID"
    type = "S"
  }

  tags = {
    Name = "dynamodb-table-submission"
  }
}

resource "aws_iam_policy" "submission-lambda-policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.submission.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "evaluate-lambda-policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ExecuteStatement",
          "dynamodb:ExecuteTransaction",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          aws_dynamodb_table.submission.arn
        ]
      }
    ]
  })
}
