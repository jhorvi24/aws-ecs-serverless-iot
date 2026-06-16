#Configuración de los Security Groups

resource "aws_security_group" "grafana-sg" {
  name        = "grafana-sg"
  description = "Security Group para acceso al dashboard"
  vpc_id      = aws_vpc.iot-ecs-red.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-iot-sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "grafana-sg"
  }
}


resource "aws_security_group" "webserver-iot-sg" {
  name        = "webserver-iot-sg"
  description = "Security Group para acceso al webserver IoT"
  vpc_id      = aws_vpc.iot-ecs-red.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "Security Group para acceso a la base de datos"
  vpc_id      = aws_vpc.iot-ecs-red.id

  ingress {
    from_port       = 8181
    to_port         = 8181
    protocol        = "tcp"
    security_groups = [aws_security_group.grafana-sg.id]
  }

  ingress {
    from_port       = 8181
    to_port         = 8181
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver-iot-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_security_group" "alb-iot-sg" {
  name        = "alb-iot-sg"
  description = "Security Group para el Application Load Balancer"
  vpc_id      = aws_vpc.iot-ecs-red.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-iot-sg"
  }

}