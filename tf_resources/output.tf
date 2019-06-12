output "mysql_endpoint" {
  value = "${aws_db_instance.mysql-instance.endpoint}"
}
