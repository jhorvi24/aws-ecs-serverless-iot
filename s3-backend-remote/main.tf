terraform {
  required_version = ">=1.10.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.30"
    }
  }
}

provider "aws" {
    region = var.aws_region
    profile = var.profile
  
}

resource "aws_s3_bucket" "bucket-terraform-state-iot-project" {
    bucket = "bucket-terraform-state-iot-project"

    lifecycle {
      prevent_destroy = true
    }

    tags = {
      Name = "bucket-terraform-state-iot-project"
      Project = var.project_name
      Environment = "dev"
      ManagedBy = "terraform"
      Purpose = "terraform-state"
    }
  
}

#Activar Versioning

resource "aws_s3_bucket_versioning" "bucket-terraform-state-iot-project" {

    bucket = aws_s3_bucket.bucket-terraform-state-iot-project.id

    versioning_configuration {
      status = "Enabled"
    }
  
}

#Cifrado en reposo

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-terraform-state-iot-project" {

    bucket = aws_s3_bucket.bucket-terraform-state-iot-project.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "aws:kms"
        }
        bucket_key_enabled = true
    }
  
}

#Bloqueo acceso publico

resource "aws_s3_bucket_public_access_block" "bucket-terraform-state-iot-project" {

    bucket = aws_s3_bucket.bucket-terraform-state-iot-project.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  
}