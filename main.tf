provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "${var.reg}"
}

resource "aws_vpc" "pr-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-app-${var.env}-${var.reg}-VPC"
  }
}

resource "aws_subnet" "pr-pub" {
  vpc_id                  = aws_vpc.pr-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone        = "${var.reg}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-app-${var.env}-${var.reg}-Subnet"
  }
}

resource "aws_internet_gateway" "pr-igw" {
  depends_on = [
    aws_vpc.pr-vpc,
    aws_subnet.pr-pub
  ]
  vpc_id = aws_vpc.pr-vpc.id
  tags = {
    Name = "Project-Internet-Gateway"
  }
}

resource "aws_route_table" "pr-rt-web" {
  depends_on = [
    aws_vpc.pr-vpc,
    aws_internet_gateway.pr-igw,
  ]
  vpc_id = aws_vpc.pr-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pr-igw.id
  }
  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

resource "aws_route_table_association" "pr-rt-association" {
  depends_on = [
    aws_vpc.pr-vpc,
    aws_subnet.pr-pub,
  ]
  subnet_id      = aws_subnet.pr-pub.id
  route_table_id = aws_route_table.pr-rt-web.id
}

resource "aws_security_group" "pr-pub-sg" {

  depends_on = [
    aws_vpc.pr-vpc,
    aws_subnet.pr-pub,
  ]

  description = "HTTP, SSH, MySQL"

  name   = "my-app-${var.env}-${var.reg}-SecurityGroup"
  tags = {
    Name = "my-app-${var.env}-${var.reg}-SecurityGroup"
  }
  vpc_id = aws_vpc.pr-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from webserver"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "${var.ami}"
  instance_type          = "t2.micro"
  subnet_id      = aws_subnet.pr-pub.id
  tags = {
    Name = "my-app-${var.env}-${var.reg}-Instance"
  }
  vpc_security_group_ids = [aws_security_group.pr-pub-sg.id]
  user_data       = file("user_data.sh")
}














