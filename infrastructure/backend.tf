terraform {
  backend "s3" {
    bucket  = "bucket-terraform-state-iot-project"          
    key     = "dev/terraform.tfstate" 
    region  = "us-east-1"
    profile = "jhorvi-aws"

    encrypt      = true  
    use_lockfile = true   #locking en S3
  }
}
