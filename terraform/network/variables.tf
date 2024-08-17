variable "region" {
  default = "us-east-1"
}

variable "prefix" {
  default = "acs730"
}

variable "env" {
  default = "prod"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.1.5.0/24", "10.1.6.0/24"]
}