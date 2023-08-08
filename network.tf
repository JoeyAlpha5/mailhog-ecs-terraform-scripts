resource "aws_vpc" "mailhog_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "mailhog-dev-vpc"
  }
}


resource "aws_subnet" "mailhog_vpc_public_subnet" {
  vpc_id                  = aws_vpc.mailhog_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "mailhog-dev-public-subnet"
  }
}


resource "aws_internet_gateway" "mailhog_vpc_igw" {
  vpc_id = aws_vpc.mailhog_vpc.id

  tags = {
    Name = "mailhog-dev-igw"
  }
}


resource "aws_route_table" "mailhog_vpc_public_rt" {
  vpc_id = aws_vpc.mailhog_vpc.id

  tags = {
    Name = "mailhog-dev-rt"
  }
}


# direct the internet gateway traffic to the public subnet
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mailhog_vpc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mailhog_vpc_igw.id

}


resource "aws_route_table_association" "mailhog_route_table_association" {
  subnet_id      = aws_subnet.mailhog_vpc_public_subnet.id
  route_table_id = aws_route_table.mailhog_vpc_public_rt.id
}


# security groups and ingress rules for inbound traffic
resource "aws_security_group" "mailhog_security_group" {
  name        = "mailhog-dev-sg"
  description = "Mailhog security group"
  vpc_id      = aws_vpc.mailhog_vpc.id

  ingress {
    description = "SMTP port for Mailhog mail server"
    from_port   = 1025
    to_port     = 1025
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP inbound traffic for Mailhog mail server"
    from_port   = 8025
    to_port     = 8025
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}