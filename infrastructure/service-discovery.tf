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


}