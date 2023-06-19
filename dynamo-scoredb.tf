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