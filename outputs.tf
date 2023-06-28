output "SubmissionQueuePublisherFunction" {
  value       = aws_lambda_function.submit_lambda.arn
  description = "SubmissionQueuePublisherFunction function name"
}

output "SubmissionQueueARN" {
  value       = aws_sqs_queue.submissionQ.arn
  description = "SQS submission queue ARN"
}

output "SubmissionQueueURL" {
  value       = aws_sqs_queue.submissionQ.url
  description = "SQS submission queue URL"
}

output "ScoreQueuePublisherFunction" {
  value       = aws_lambda_function.evaluate_lambda.arn
  description = "ScoreQueuePublisherFunction function name"
}

output "ScoreQueueARN" {
  value       = aws_sqs_queue.scoreQ.arn
  description = "SQS Score queue ARN"
}

output "ScoreQueueURL" {
  value       = aws_sqs_queue.scoreQ.url
  description = "SQS Score queue URL"
}