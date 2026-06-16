#Servicios de la infraestructura de red de 3 capas en una zona de disponibilidad

#Configuración del VPC

resource "aws_vpc" "iot-ecs-red" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "iot-ecs-red"
  }

}

#Configuración de las 3 subredes


resource "aws_subnet" "subred-publica-A" {
  vpc_id                  = aws_vpc.iot-ecs-red.id
  cidr_block              = var.cidr_subnet_public_a
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-public-a"
  }
}

resource "aws_subnet" "subred-publica-B" {
  vpc_id                  = aws_vpc.iot-ecs-red.id
  cidr_block              = var.cidr_subnet_public_b
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-public-b"
  }
}

resource "aws_subnet" "subred-privada-A" {
  vpc_id                  = aws_vpc.iot-ecs-red.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "subred-privada-A"
  }
}


#Configuración del Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.iot-ecs-red.id
  tags = {
    Name = "iot-ecs-igw"
  }

}

#Configuración de las Routes Tables

resource "aws_route_table" "rt-public-igw" {
  vpc_id = aws_vpc.iot-ecs-red.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rt-public-igw"
  }
}


#Asociación de las routes tables con la subredes

resource "aws_route_table_association" "rt-igw-a-association" {
  subnet_id      = aws_subnet.subred-publica-A.id
  route_table_id = aws_route_table.rt-public-igw.id
}

resource "aws_route_table_association" "rt-igw-b-association" {
  subnet_id      = aws_subnet.subred-publica-B.id
  route_table_id = aws_route_table.rt-public-igw.id

}

#Configuración del nat gateway

resource "aws_eip" "eip-nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.subred-publica-A.id
  tags = {
    Name = "ngw"
  }

}

resource "aws_route_table" "rt-private-ngw" {
  vpc_id = aws_vpc.iot-ecs-red.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "rt-private-ngw"
  }

}

resource "aws_route_table_association" "rt-ngw-association" {
  subnet_id      = aws_subnet.subred-privada-A.id
  route_table_id = aws_route_table.rt-private-ngw.id

}







