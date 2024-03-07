# IAM role
resource "aws_iam_role" "photogram_role" {
  name = "photogram-IAM-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach policies to IAM role
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.photogram_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_access" {
  role       = aws_iam_role.photogram_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}