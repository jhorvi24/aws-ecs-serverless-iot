terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.30"
    }
  }
}

provider "aws" {

  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {

      Project = "IoT-ECS"
      environment = "dev"
      managed = "terraform"
      
    }
    
  }

}