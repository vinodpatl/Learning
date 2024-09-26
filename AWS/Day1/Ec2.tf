## Created aws infra for Ec2, Vpc
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.50.0"
    }
  }
}
provider "aws" {
  region     = "ap-south-1"
}
resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"

  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-ig"
  }
}

resource "aws_route_table" "my_routing_table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "my_routing_table"
  }
}

resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "my-subnet"
  }
}

resource "aws_route_table_association" "my_rtassociation" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my_routing_table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vinod-sg"
  }
}



resource "aws_instance" "web" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my-subnet.id
  associate_public_ip_address = "true"
  key_name = "Mumbai"
  user_data = <<-EOF
               #!/bin/bash
               sudo apt update -y
               new_user="vinod"
               password="password123"
               sudo useradd -m $new_user
               sudo usermod -aG sudo $new_user
               echo "$new_user:$password" | sudo chpasswd
              EOF
  tags = {
    Name = "my_test server"
  }
}


