terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "ghost" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "cloudx"
    Project = "cloudx"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.ghost.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name    = "public_a"
    Project = "cloudx"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.ghost.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name    = "public_b"
    Project = "cloudx"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.ghost.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name    = "public_c"
    Project = "cloudx"
  }
}

resource "aws_internet_gateway" "ghost" {
  vpc_id = aws_vpc.ghost.id

  tags = {
    Name    = "cloudx-igw"
    Project = "cloudx"
  }
}
