terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.default_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "main"
}

# Create a VPC
resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "default"
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id
}

resource "aws_subnet" "ec2" {
    vpc_id            = aws_vpc.default.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = var.default_region_az
    map_public_ip_on_launch = true
    depends_on = [aws_internet_gateway.gw]

    tags = {
    Name = "ec2"
    }
}

resource "aws_instance" "windows" {
  ami           = "ami-029bfac3973c1bda1" # Microsoft Windows Server 2019 Base
  instance_type = "t2.micro"
  get_password_data = true

  private_ip = "10.0.1.100"
  subnet_id  = aws_subnet.ec2.id
}

resource "aws_eip" "windows" {
  vpc = true

  instance                  = aws_instance.windows.id
  associate_with_private_ip = "10.0.1.100"
  depends_on                = [aws_internet_gateway.gw]
}

