variable "aws_region" {

    description = "AWS Region"
    type = string
    default = "us-east-1"
  
}

variable "aws_profile" {

    description = "AWS profile"
    type = string
    default = "jhorvi-aws"
  
}

variable "vpc_cidr" {

    description = "VPC CIDR"
    type = string
    default = "10.0.0.0/16"
  
}

variable "cidr_subnet_public_a" {
    description = "Subnet Public A CIRD"
    type = string
    default = "10.0.1.0/24"
  
}

variable "cidr_subnet_public_b" {
    description = "Subnet Public B CIRD"
    type = string
    default = "10.0.3.0/24"
  
}

variable "cidr_subnet_private_a" {
    description = "Subnet Private A CIRD"
    type = string
    default = "10.0.2.0/24"
  
}

variable "cidr_subnet_private_b" {
    description = "Subnet Private B CIRD"
    type = string
    default = "10.0.4.0/24"
  
}

variable "cidr_subnet_private_aa" {
    description = "Subnet Private AA CIRD"
    type = string
    default = "10.0.5.0/24"
  
}