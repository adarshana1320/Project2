#Public subnet creation
locals {
  az_names     = data.aws_availability_zones.azs.names
  pub_sub_ids  = aws_subnet.public.*.id
  priv_sub_ids = aws_subnet.private.*.id
}
resource "aws_subnet" "public" {
  count                   = length(local.az_names)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

#Internet gateway creation
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "TerraformIGW"
  }
}

#public route-table creation
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "TerraformPublic-RT"
  }
}

#Route-table association
resource "aws_route_table_association" "pub_sub_association" {
  count          = length(local.az_names)
  subnet_id      = local.pub_sub_ids[count.index]
  route_table_id = aws_route_table.public-rt.id
}
