# Create VPC
resource "aws_vpc" "photogram_vpc" {
  cidr_block           = "172.40.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "photogram-VPC"
  }
}

# Create subnets
resource "aws_subnet" "photogram_subnet_1a" {
  vpc_id                  = aws_vpc.photogram_vpc.id
  cidr_block              = "172.40.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true # This will allow instances in this subnet to have public IP addresses
  tags = {
    Name = "photogram-SUBNET-1a"
  }
}

resource "aws_subnet" "photogram_subnet_1c" {
  vpc_id                  = aws_vpc.photogram_vpc.id
  cidr_block              = "172.40.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "photogram-SUBNET-1c"
  }
}

resource "aws_subnet" "photogram_subnet_1d" {
  vpc_id                  = aws_vpc.photogram_vpc.id
  cidr_block              = "172.40.2.0/24"
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = true
  tags = {
    Name = "photogram-SUBNET-1d"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "photogram_igw" {
  vpc_id = aws_vpc.photogram_vpc.id
  tags = {
    Name = "photogram-IGW"
  }
}

# Create Route Table
resource "aws_route_table" "photogram_rt" {
  vpc_id = aws_vpc.photogram_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.photogram_igw.id
  }

  route {
    cidr_block = "172.40.0.0/16"
  }

  tags = {
    Name = "photogram-RT"
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "photogram_rt_association_1a" {
  subnet_id      = aws_subnet.photogram_subnet_1a.id
  route_table_id = aws_route_table.photogram_rt.id
}

resource "aws_route_table_association" "photogram_rt_association_1c" {
  subnet_id      = aws_subnet.photogram_subnet_1c.id
  route_table_id = aws_route_table.photogram_rt.id
}

resource "aws_route_table_association" "photogram_rt_association_1d" {
  subnet_id      = aws_subnet.photogram_subnet_1d.id
  route_table_id = aws_route_table.photogram_rt.id
}
