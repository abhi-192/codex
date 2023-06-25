resource "aws_sqs_queue" "scoreQ" {
  name                      = "scoreQ"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1200
  receive_wait_time_seconds = 0
  sqs_managed_sse_enabled   = true
}
