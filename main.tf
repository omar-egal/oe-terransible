# Get availability zones
data "aws_availability_zones" "available" {}

# Create random resource for tags
resource "random_id" "random" {
  byte_length = 2
}

# Create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my-vpc-${random_id.random.dec}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "terransible_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "terransible-igw-${random_id.random.dec}"
  }
}

# Create route table for plublic route to internet
resource "aws_route_table" "terransible_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "terransible-public"
  }
}

# Create default public route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.terransible_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terransible_igw.id
}

# Create default private route table
resource "aws_default_route_table" "terransible_private_rt" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  tags = {
    Name = "terransible-private"
  }
}

# Create public subnet(s)
resource "aws_subnet" "terransible_public_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "terransible-plublic-${count.index + 1}"
  }
}

# Create private subnet(s)
resource "aws_subnet" "terransible_private_subnet" {
  count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "terransible-private-${count.index + 1}"
  }
}