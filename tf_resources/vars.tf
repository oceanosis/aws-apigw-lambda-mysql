variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default= "ami-0009a33f033d8b7b6"
}
variable "trusted_ip_range" {}

variable "RDS_MULTI_AZ" {
  default = "false"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "RDS_USERNAME" {}
variable "RDS_PASSWORD" {}
variable "RDS_DBNAME" {}

variable "PATH_TO_PRIVATE_KEY" {
  default = "automation"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "automation.pub"
}