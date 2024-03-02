resource "aws_sqs_queue" "photogram_SQS" {
  name                        = "photogram_SQS.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}