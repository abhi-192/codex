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
