variable "region" {
  default = "us-east-1"
}

variable "prefix" {
  default = "acs730"
}

variable "env" {
  default = "prod"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "state_bucket" {
  default = "acs730-final-prod-sgaire3-bucket"
  description = "S3 bucket containing the network state file"
}

