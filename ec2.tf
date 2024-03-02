//webserver ec2 instance
resource "aws_instance" "photogram_webserver" {
  ami           = "ami-0440d3b780d96b29d" # Replace with your desired AMI ID
  instance_type = "t2.micro"              # Or any instance type you prefer

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nodejs npm --enablerepo=epel",
      "sudo npm install -g forever",
      "mkdir web",
      "aws s3 sync --region=ap-northeast-1 s3://photogram.src/web web",
      "cd web",
      "npm install"
    ]
  }
}

resource "aws_security_group" "photogram_webserver_sg" {
  name        = "photogram-webserver-sg"
  description = "Security group for Photogram web servers"
  vpc_id      = aws_vpc.photogram_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "photogram_asg_sg" {
  name        = "photogram-asg-sg"
  description = "Security group for Photogram auto scaling groups"
  vpc_id      = aws_vpc.photogram_vpc.id

  ingress {
    from_port   = 22
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ami_from_instance" "photogram_webserver_ami" {
  name               = "photogram_webserver_ami"
  source_instance_id = aws_instance.photogram_webserver.id
}

resource "aws_launch_configuration" "photogram_webserver_lc" {
  name            = "photogram_webserver_lc"
  image_id        = aws_ami_from_instance.photogram_webserver_ami.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.photogram_webserver_sg.id] # Specify your security group ID
  key_name        = "your_key_pair"                                # Specify your key pair name
  user_data       = <<-EOF
              #!/bin/bash
              cd /home/ec2-user
              aws s3 sync --region=ap-northeast-1 \
               s3://examplephoto.src/ExamplePhotoWebServer ExamplePhotoWebServer
              cd ExamplePhotoWebServer
              npm install
              forever start -w app.js
              EOF
}

resource "aws_autoscaling_group" "photogram_webserver_asg" {
  name                 = "photogram_webserver_asg"
  launch_configuration = aws_launch_configuration.photogram_webserver_lc.name
  min_size             = 1                                # Minimum number of instances
  max_size             = 5                                # Maximum number of instances
  desired_capacity     = 2                                # Desired number of instances
  vpc_zone_identifier  = [aws_subnet.photogram_subnet.id] # Specify your subnet IDs # Specify your target group ARN if using ALB/NLB
  load_balancers       = [aws_elb.photogram_ELB.name]
  enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  metrics_granularity  = "1Minute"
}


resource "aws_autoscaling_policy" "cpu_scaling_policy" {
  name                   = "cpu_scaling_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.photogram_webserver_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80 # Set the desired target value (e.g., 50 for 50% CPU utilization)
  }


}

//resizer ec2 instance
resource "aws_instance" "photogram_resizer" {
  ami                  = "ami-0440d3b780d96b29d" # Replace with your desired AMI ID
  instance_type        = "t2.micro"              # Or any instance type you prefer
  iam_instance_profile = aws_iam_instance_profile.photogram_resizer_profile.name

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nodejs npm --enablerepo=epel",
      "sudo yum install -y ImageMagick",
      "sudo npm install -g forever",
      "mkdir resize",
      "aws s3 sync --region=ap-northeast-1 s3://photogram.src/resize resize",
      "cd resize",
      "npm install",
      "forever start -w app.js"
    ]
  }
}
resource "aws_iam_instance_profile" "photogram_resizer_profile" {
  name = "photogram_resizer_profile"
  role = aws_iam_role.photogram_Role.name
}