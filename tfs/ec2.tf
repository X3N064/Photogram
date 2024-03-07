# IAM Role
resource "aws_iam_role" "photogram_iam_role" {
  name = "photogram-IAM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach policies to IAM role
resource "aws_iam_role_policy_attachment" "photogram_iam_role_attachment" {
  role       = aws_iam_role.photogram_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "photogram_sqs_iam_role_attachment" {
  role       = aws_iam_role.photogram_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

# Create EC2 instance for web
resource "aws_instance" "photogram_ec2_web" {
  ami                    = "ami-0ba62e8b17d6d1c85"
  instance_type          = "t2.micro"
  key_name               = "photogram-keypair"
  subnet_id              = aws_subnet.photogram_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.photogram_mysql_sg.id, aws_security_group.photogram_need_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.photogram_instance_profile.name
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nodejs npm",
      "sudo npm install -g forever",
      "mkdir web",
      "aws s3 sync --region=ap-northeast-1 s3://photogram-s3-src/web web",
      "cd web",
      "npm install",
      "forever start -w app.js"
    ]
  }
  tags = {
    Name = "photogram-EC2-web"
  }
}

# Create EC2 instance for resizer
resource "aws_instance" "photogram_ec2_resizer" {
  ami                    = "ami-0970c6bc7b40d08ed"
  instance_type          = "t2.micro"
  key_name               = "photogram-keypair"
  subnet_id              = aws_subnet.photogram_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.photogram_mysql_sg.id, aws_security_group.photogram_need_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.photogram_instance_profile.name
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nodejs npm",
      "sudo yum install -y ImageMagick",
      "sudo npm install -g forever",
      "mkdir resize",
      "aws s3 sync --region=ap-northeast-1 s3://photogram-s3-src/resize resize",
      "cd resize",
      "npm install",
      "forever start -w app.js"
    ]
  }
  tags = {
    Name = "photogram-EC2-resizer"
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "photogram_instance_profile" {
  name = "photogram-IAM-Instance-Profile"
  role = aws_iam_role.photogram_iam_role.name
}
# Create Launch Template
resource "aws_launch_template" "photogram_lt" {
  name_prefix   = "photogram-LT"
  image_id      = "ami-0495de9cb66b9ac76"
  instance_type = "t2.micro"
  key_name      = "photogram-keypair"
  user_data     = <<-EOF
                  #!/bin/bash
                  cd /home/ec2-user
                  aws s3 sync --region=ap-northeast-1 s3://photogram-s3-src/web web
                  cd web
                  npm install
                  forever start -w app.js
                  EOF

  iam_instance_profile {
    arn = aws_iam_instance_profile.photogram_instance_profile.arn
  }

  security_group_names = ["photogram-need", "photogram-MySQL"]
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "photogram_asg" {
  name                = "photogram-ASG"
  min_size            = 1
  max_size            = 5
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.photogram_subnet_1a.id, aws_subnet.photogram_subnet_1c.id, aws_subnet.photogram_subnet_1d.id] # You may need to add more subnets here
  launch_template {
    id      = aws_launch_template.photogram_lt.id
    version = "$Latest"
  }
}