resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr_vpc
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

locals {
  zone = ["a", "b", "c"]
}

resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.cidr_public, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public-subnet-${element(local.zone, count.index)}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.cidr_private, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.prefix}-private-subnet-${element(local.zone, count.index)}"
  }
}

resource "aws_subnet" "database" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.cidr_database, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.prefix}-database-subnet-${element(local.zone, count.index)}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-rt"
  }

}

resource "aws_route_table_association" "rta" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rt.id
}