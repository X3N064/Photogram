# Create SQS Queue
resource "aws_sqs_queue" "photogram_sqs" {
  name              = "photogram-SQS"
  fifo_queue        = false           # Standard SQS queue
  kms_master_key_id = "alias/aws/sqs" # Using the default AWS managed key for SSE-SQS
  tags = {
    Name = "photogram-SQS"
  }
}
