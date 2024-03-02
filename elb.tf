resource "aws_elb" "photogram_ELB" {
  name               = "photogram-ELB"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"] // Add appropriate availability zones
  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
}
