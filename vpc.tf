resource "aws_vpc" "photogram_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "photogram_vpc"
  }
}

resource "aws_subnet" "photogram_subnet" {
  vpc_id                  = aws_vpc.photogram_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "photogram_subnet"
  }
}

resource "aws_internet_gateway" "photogram_IG" {
  vpc_id = aws_vpc.photogram_vpc.id
  tags = {
    Name = "photogram_IG"
  }
}

resource "aws_route_table" "photogram_RT" {
  vpc_id = aws_vpc.photogram_vpc.id
  tags = {
    Name = "photogram_RT"
  }
}

resource "aws_route" "photogram_Route" {
  route_table_id         = aws_route_table.photogram_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.photogram_IG.id
}

resource "aws_route_table_association" "name" {
  subnet_id      = aws_subnet.photogram_subnet.id
  route_table_id = aws_route.photogram_Route.id
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow MySQL inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.photogram_vpc.id

  tags = {
    Name = "allow_mysql"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_ipv4" {
  security_group_id = aws_security_group.allow_mysql.id
  cidr_ipv4         = aws_vpc.photogram_vpc.cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_mysql.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
