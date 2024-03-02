resource "aws_iam_role" "photogram_Role" {
  name = "photogram_Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "photogram_S3_Full_Access"
  roles      = [aws_iam_role.photogram_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "sqs_full_access" {
  name       = "photogram_SQS_Full_Access"
  roles      = [aws_iam_role.photogram_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
