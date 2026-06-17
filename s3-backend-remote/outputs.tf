output "bucket_name" {
  description = "Nombre del bucket S3 para el estado de Terraform"
  value       = aws_s3_bucket.bucket-terraform-state-iot-project.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.bucket-terraform-state-iot-project.arn
}