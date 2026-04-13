# Dead Letter Queue
resource "aws_sqs_queue" "reservation_dlq" {
  name                        = "${var.env}-ticketing-reservation-dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  message_retention_seconds   = 1209600 # 14일

  tags = {
    Name        = "${var.env}-ticketing-reservation-dlq"
    Environment = var.env
  }
}

# 메인 FIFO 큐
resource "aws_sqs_queue" "reservation" {
  name                        = "${var.env}-ticketing-reservation.fifo"
  fifo_queue                  = true
  content_based_deduplication = true

  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.reservation_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.env}-ticketing-reservation"
    Environment = var.env
  }
}

# SSM 등록 
resource "aws_ssm_parameter" "reservation_queue_url" {
  name  = "/${var.env}/ticketing/sqs/reservation/url"
  type  = "String"
  value = aws_sqs_queue.reservation.url
}

resource "aws_ssm_parameter" "reservation_queue_arn" {
  name  = "/${var.env}/ticketing/sqs/reservation/arn"
  type  = "String"
  value = aws_sqs_queue.reservation.arn
}