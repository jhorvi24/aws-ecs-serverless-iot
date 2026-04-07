resource "aws_ecs_cluster" "IoT-cluster" {

  name = "IoT-cluster"

}

#Configure the tasks definitions

resource "aws_ecs_task_definition" "webserver-iot-task-definition" {

  family                   = "webserver-iot-taskdefinition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "3 GB"
  cpu                      = "1 vCPU"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "webserver-iot"
      image = "001239102331.dkr.ecr.us-east-1.amazonaws.com/web-server-iot:latest"
      environment = [
        {
          name  = "INFLUX_DB"
          value = "sensor-db"
        },
        {
          name  = "INFLUX_HOST"
          value = "http://influxdb-core.db.local:8181"
        },
        {
          name  = "INFLUX_TOKEN"
          value = ""
        }
      ]
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/webserver-iot"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group": "true"
        }
      }
    }



  ])

}

resource "aws_ecs_task_definition" "influxdb-task-definition" {

  family                   = "influxdb-taskdefinition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "3 GB"
  cpu                      = "1 vCPU"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name    = "influxdb-core"
      image   = "influxdb:3-core"
      command = ["influxdb3", "serve", "--node-id=my-node-0", "--object-store=file", "--data-dir=/var/lib/influxdb3/data", "--plugin-dir=/var/lib/influxdb3/plugins", "--without-auth"]
      portMappings = [
        {
          containerPort = 8181
          hostPort      = 8181
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/influxdb-core"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group": "true"
        }
      }
    }



  ])

}

resource "aws_ecs_task_definition" "grafana-task-definition" {

  family                   = "grafana-taskdefinition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "3 GB"
  cpu                      = "1 vCPU"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "grafana-iot"
      image = "grafana/grafana-enterprise"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/grafana-iot"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group": "true"
        }
      }

    }



  ])

}


#Configure the services

resource "aws_ecs_service" "webserver-iot-service" {
  name            = "webserver-iot-service"
  cluster         = aws_ecs_cluster.IoT-cluster.id
  task_definition = aws_ecs_task_definition.webserver-iot-task-definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.subred-publica-A.id, aws_subnet.subred-publica-B.id]
    security_groups = [aws_security_group.webserver-iot-sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.webserver-iot-tg.arn
    container_name   = "webserver-iot"
    container_port   = 5000
  }

}

resource "aws_ecs_service" "influxdb-service" {
  name            = "influxdb-service"
  cluster         = aws_ecs_cluster.IoT-cluster.id
  task_definition = aws_ecs_task_definition.influxdb-task-definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.subred-privada-A.id]
    security_groups = [aws_security_group.db-sg.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.influxdb-service-discovery.arn
  }

}

#Service discovery for communication between services

resource "aws_service_discovery_private_dns_namespace" "db_local" {
  name        = "db.local"
  description = "Namespace for database services"
  vpc         = aws_vpc.iot-ecs-red.id
}

resource "aws_service_discovery_service" "influxdb-service-discovery" {
  name         = "influxdb-core"
  namespace_id = aws_service_discovery_private_dns_namespace.db_local.id

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.db_local.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1

  }
}


resource "aws_ecs_service" "grafana-service" {
  name            = "grafana-service"
  cluster         = aws_ecs_cluster.IoT-cluster.id
  task_definition = aws_ecs_task_definition.grafana-task-definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.subred-publica-A.id, aws_subnet.subred-publica-B.id]
    security_groups  = [aws_security_group.grafana-sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.grafana-tg.arn
    container_name   = "grafana-iot"
    container_port   = 3000
  }

}