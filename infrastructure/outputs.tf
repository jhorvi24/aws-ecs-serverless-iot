output "alb_dns_name" {
  description = "DNS name del ALB"
  value       = aws_lb.alb-iot.dns_name

}

output "alb_arn" {
  description = "ARN del ALB"
  value       = aws_lb.alb-iot.arn
}

output "ecs_cluster_name" {
  description = "Nombre del ECS Cluster"
  value       = aws_ecs_cluster.IoT-cluster.name
}