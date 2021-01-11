############ DEFAULT VPC ############
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

############ INTERNET GATEWAY DATA ############
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

############ PUBLIC SUBNETS ############
resource "aws_subnet" "public-101" {
  vpc_id            = aws_default_vpc.default.id
  availability_zone = "us-east-1a"
  cidr_block        = "172.31.101.0/24"
  tags = {
    Name = "PUBLIC-101"
  }
}
resource "aws_subnet" "public-102" {
  vpc_id            = aws_default_vpc.default.id
  availability_zone = "us-east-1a"
  cidr_block        = "172.31.102.0/24"
  tags = {
    Name = "PUBLIC-102"
  }
}
resource "aws_subnet" "public-103" {
  vpc_id            = aws_default_vpc.default.id
  availability_zone = "us-east-1a"
  cidr_block        = "172.31.103.0/24"
  tags = {
    Name = "PUBLIC-103"
  }
}

############ PUBLIC ROUTE TABLE ############
resource "aws_route_table" "public" {
  vpc_id = aws_default_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }
  tags = {
    Name = "PUBLIC-ROUTES"
  }
}

resource "aws_route_table_association" "public-101" {
  subnet_id      = aws_subnet.public-101.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-102" {
  subnet_id      = aws_subnet.public-102.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-103" {
  subnet_id      = aws_subnet.public-103.id
  route_table_id = aws_route_table.public.id
}
