# Create ELB
resource "aws_lb" "photogram_elb" {
  name               = "photogram-ELB"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.photogram_subnet_1a.id,
    aws_subnet.photogram_subnet_1c.id,
    aws_subnet.photogram_subnet_1d.id
  ]
  ip_address_type = "ipv4"
  security_groups = [aws_security_group.photogram_need_sg.id] # You may want to specify security groups here if needed
}

# Create Target Group
resource "aws_lb_target_group" "photogram_tg" {
  name        = "photogram-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.photogram_vpc.id
  health_check {
    protocol = "HTTP"
    path     = "/"
    port     = "80"
  }
}

# Attach Target Group to ELB
resource "aws_lb_target_group_attachment" "photogram_tg_attachment" {
  target_group_arn = aws_lb_target_group.photogram_tg.arn
  target_id        = aws_instance.photogram_ec2_web.id
}
