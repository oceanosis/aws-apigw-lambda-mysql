variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "trusted_ip_range" {
  default = "0.0.0.0/0"
}

variable "RDS_MULTI_AZ" {
  default = "false"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "RDS_USERNAME" {}
variable "RDS_PASSWORD" {}
variable "RDS_DBNAME" {}
