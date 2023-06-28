resource "aws_dynamodb_table" "score" {
  name           = "score"
  hash_key       = "userID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  attribute {
    name = "userID"
    type = "S"
  }

  tags = {
    Name = "dynamodb-table-score"
  }
}

resource "aws_iam_policy" "score-lambda-policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem"
        ]
        Resource = [
          aws_dynamodb_table.score.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "worker-lambda-policy" {
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
          aws_dynamodb_table.score.arn
        ]
      }
    ]
  })
}
