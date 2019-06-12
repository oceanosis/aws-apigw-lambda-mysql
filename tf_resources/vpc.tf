module "hwvpc" {

source   = "./vpc"
vpc_name = "hw-vpc"
trusted_ip_range = "${var.trusted_ip_range}"

}
