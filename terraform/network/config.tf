terraform {
  backend "s3" {
    bucket = "acs-730-final-group9-bucket"
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}