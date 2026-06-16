#Configuración del load balancer

resource "aws_lb" "alb-iot" {
  name               = "alb-iot"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-iot-sg.id]
  subnets            = [aws_subnet.subred-publica-A.id, aws_subnet.subred-publica-B.id]

  tags = {
    Name = "alb-iot"
  }

}

#Configuración de los target groups

resource "aws_lb_target_group" "webserver-iot-tg" {
  name        = "webserver-iot-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.iot-ecs-red.id
  target_type = "ip" #Obligatorio para fargate

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "target-group-iot"
  }

}

resource "aws_lb_target_group" "grafana-tg" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.iot-ecs-red.id
  target_type = "ip" #Obligatorio para fargate

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "grafana-tg"
  }

}


resource "aws_lb_listener" "alb-iot-http" {
  load_balancer_arn = aws_lb.alb-iot.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana-tg.arn
  }


}

resource "aws_lb_listener_rule" "alb-iot-rule" {
  listener_arn = aws_lb_listener.alb-iot-http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/data"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-iot-tg.arn
  }

}