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
  cidr_block              = var.cidr_subnet_private_a
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "subred-privada-A"
  }
}

resource "aws_subnet" "subred-privada-B" {
  vpc_id                  = aws_vpc.iot-ecs-red.id
  cidr_block              = var.cidr_subnet_private_b
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "subred-privada-B"
  }
}

resource "aws_subnet" "subred-privada-AA" {
  vpc_id                  = aws_vpc.iot-ecs-red.id
  cidr_block              = var.cidr_subnet_private_aa
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "subred-privada-AA"
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

#Configuración del nat gateway A y nat gateway B

resource "aws_eip" "eip-nat-a" {
  domain = "vpc"
}

resource "aws_eip" "eip-nat-b" {
  domain = "vpc"
  
}

resource "aws_nat_gateway" "ngw-a" {
  allocation_id = aws_eip.eip-nat-a.id
  subnet_id     = aws_subnet.subred-publica-A.id
  tags = {
    Name = "ngw-a"
  }

}

resource "aws_nat_gateway" "ngw-b" {
  allocation_id = aws_eip.eip-nat-b.id
  subnet_id     = aws_subnet.subred-publica-B.id
  tags = {
    Name = "ngw-b"
  }

}

#Creación de las tablas de enrutamiento para los NatGateway

resource "aws_route_table" "rt-private-ngw-a" {
  vpc_id = aws_vpc.iot-ecs-red.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw-a.id
  }
  tags = {
    Name = "rt-private-ngw-a"
  }

}

resource "aws_route_table" "rt-private-ngw-b" {
  vpc_id = aws_vpc.iot-ecs-red.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw-b.id
  }
  tags = {
    Name = "rt-private-ngw-b"
  }

}

#Asociaciones de la route tables con las subnets

resource "aws_route_table_association" "rt-ngw-association-a" {
  subnet_id      = aws_subnet.subred-privada-A.id
  route_table_id = aws_route_table.rt-private-ngw-a.id

}

resource "aws_route_table_association" "rt-ngw-association-aa" {
  subnet_id      = aws_subnet.subred-privada-AA.id
  route_table_id = aws_route_table.rt-private-ngw-a.id

}

resource "aws_route_table_association" "rt-ngw-association-b" {
  subnet_id      = aws_subnet.subred-privada-B.id
  route_table_id = aws_route_table.rt-private-ngw-b.id

}






