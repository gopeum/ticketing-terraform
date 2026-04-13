output "reservation_queue_url" {
  value = aws_sqs_queue.reservation.url
}

output "reservation_queue_arn" {
  value = aws_sqs_queue.reservation.arn
}

output "reservation_dlq_arn" {
  value = aws_sqs_queue.reservation_dlq.arn
}

# SSM
output "reservation_queue_url_ssm" {
  value = aws_ssm_parameter.reservation_queue_url.name
}

output "reservation_queue_arn_ssm" {
  value = aws_ssm_parameter.reservation_queue_arn.name
}