terraform {
  backend "s3" {
    bucket = "acs730-final-prod-sgaire3-bucket"
    key    = "dev/webserver/terraform.tfstate"
    region = "us-east-1"
  }
}