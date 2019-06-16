output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "private_subnet_ids" {
  value = ["${aws_subnet.main-private-1.id}", "${aws_subnet.main-private-2.id}","${aws_subnet.main-private-3.id}"]
}

output "public_subnet_ids" {
  value = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}", "${aws_subnet.main-public-3.id}"]
}

output "private_availability_zones" {
  value = ["${aws_subnet.main-private-1.availability_zone}","${aws_subnet.main-private-2.availability_zone}","${aws_subnet.main-private-3.availability_zone}"]
}

