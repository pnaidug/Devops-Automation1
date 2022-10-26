#create vpc with stage
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name      = "stage-vpc"
    terraform = "true"
  }
}
#IGw creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Stage-igw"
  }
  depends_on = [
    aws_vpc.vpc]
}
# create a region
# create cidr




# create subnets
#public
resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pub_cidr,count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-public-${count.index+1}-subnet"
  }
}
resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.private_cidr,count.index)
#   map_public_ip_on_launch = "true"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "satge-private-${count.index+1}-subnet"
  }
}
resource "aws_subnet" "data" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.data_cidr,count.index)
#   map_public_ip_on_launch = "true"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-data-${count.index+1}-subnet"
  }
}
# resource "aws_subnet" "public1" {
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = "10.1.1.0/24"
# map_public_ip_on_launch="true"
# availability_zone = data.aws_availability_zones.available.names[1]

#   tags = {
#     Name = "public-2-subnet"
#   }
# }
# resource "aws_subnet" "public2" {
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = "10.1.2.0/24"
#   availability_zone = data.aws_availability_zones.available.names[2]
# map_public_ip_on_launch="true"
#   tags = {
#     Name = "public-3-subnet"
#   }
# }
#eip
resource "aws_eip" "eip" {
  #instance = aws_instance.web.id
  vpc      = true
   tags = {
    Name = "stage-eip"
  }
}
#Nat-gw
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "stage-Natgw"
  }
  depends_on = [aws_eip.eip]
}
#Routetable
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
 

  tags = {
    Name = "stage-pub-route"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
 

  tags = {
    Name = "stage-private-route"
  }
  depends_on = [
    aws_nat_gateway.natgw
  ]
}

#route table asication

resource "aws_route_table_association" "public" {
    count         = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count         = length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "data" {
    count         = length(aws_subnet.data[*].id)
  subnet_id      = element(aws_subnet.data[*].id,count.index)
  route_table_id = aws_route_table.private.id
}


#private

#data

#create Igw

# crerate nat-gw
#EIp

#routltable
#assocaite
#route
