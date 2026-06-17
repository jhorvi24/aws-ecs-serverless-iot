variable "aws_region" {
  description = "Región de AWS donde se crea el bucket"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "Perfil de AWS CLI"
  type        = string
  default     = "jhorvi-aws"
  
}


variable "project_name" {
  description = "Nombre del proyecto (parte del nombre del bucket)"
  type        = string
  default = "iot-ecs"
}