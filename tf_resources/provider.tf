provider "aws" { 
    version    = "~> 2.0"
    access_key = "${var.AWS_ACCESS_KEY}"
    secret_key = "${var.AWS_SECRET_KEY}"
    region     = "${var.AWS_REGION}"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "helloworld-tf-states"
    key    = "tf_states/terraform.tfstate"
    dynamodb_table = "helloworld-tf-states"
    region = "eu-west-2"
  }
}
