terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {

    region = "us-east-1"
    profile = "jhorvi-aws"
  
}


#Servicios de la infraestructura de red de 3 capas en una zona de disponibilidad

#Configuración del VPC

resource "aws_vpc" "iot-ecs-red" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "iot-ecs-red"
    }
  
}

#Configuración de las 3 subredes


resource "aws_subnet" "subred-publica-A" {
    vpc_id = aws_vpc.iot-ecs-red.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-public-a"
    }
}

resource "aws_subnet" "subred-publica-B" {
    vpc_id = aws_vpc.iot-ecs-red.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-public-b"
    }
}

resource "aws_subnet" "subred-privada-A" {
    vpc_id = aws_vpc.iot-ecs-red.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
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
    subnet_id = aws_subnet.subred-publica-A.id
    route_table_id = aws_route_table.rt-public-igw.id
}

resource "aws_route_table_association" "rt-igw-b-association" {
    subnet_id = aws_subnet.subred-publica-B.id
    route_table_id = aws_route_table.rt-public-igw.id
  
}

#Configuración del nat gateway

resource "aws_eip" "eip-nat" {
    domain = "vpc"    
}

resource "aws_nat_gateway" "ngw"{
    allocation_id = aws_eip.eip-nat.id
    subnet_id = aws_subnet.subred-publica-A.id
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
    subnet_id = aws_subnet.subred-privada-A.id
    route_table_id = aws_route_table.rt-private-ngw.id
  
}

#Configuración del load balancer

resource "aws_lb" "alb-iot" {
    name = "alb-iot"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.alb-iot-sg.id ]
    subnets = [ aws_subnet.subred-publica-A.id, aws_subnet.subred-publica-B.id ]

    tags = {
        Name = "alb-iot"
    }

}

#Configuración de los target groups

/* resource "aws_lb_target_group" "webserver-iot" {
    name = "webserver-iot"
    port = 5000
    protocol = "HTTP"
    vpc_id = aws_vpc.iot-ecs-red.id
    target_type = "ip"  #Obligatorio para fargate

    health_check {
        path = "/health"
        interval = 30
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = "target-group-iot"
    }

} */



#Configuración de los Security Groups

resource "aws_security_group" "grafana-sg" {
    name = "grafana-sg"
    description = "Security Group para acceso al dashboard"
    vpc_id = aws_vpc.iot-ecs-red.id

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "grafana-sg"
    }
}


resource "aws_security_group" "webserver-iot-sg" {
    name = "webserver-iot-sg"
    description = "Security Group para acceso al webserver IoT"
    vpc_id = aws_vpc.iot-ecs-red.id
    
    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  
}

resource "aws_security_group" "db-sg" {
    name = "db-sg"
    description = "Security Group para acceso a la base de datos"
    vpc_id = aws_vpc.iot-ecs-red.id

    ingress {
        from_port = 8181
        to_port = 8181
        protocol = "tcp"
        security_groups = [ aws_security_group.grafana-sg.id ]
    }

     ingress {
        from_port = 8181
        to_port = 8181
        protocol = "tcp"
        security_groups = [ aws_security_group.webserver-iot-sg.id ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "db-sg"
    }
}

resource "aws_security_group" "alb-iot-sg" {
    name = "alb-iot-sg"
    description = "Security Group para el Application Load Balancer"
    vpc_id = aws_vpc.iot-ecs-red.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "alb-iot-sg"
    }
  
}

