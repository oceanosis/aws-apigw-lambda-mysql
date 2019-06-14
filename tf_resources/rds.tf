resource "aws_db_subnet_group" "mysql-subnet" {
    name = "mysql-subnet"
    description = "RDS subnet group"
    subnet_ids = "${module.hwvpc.private_subnet_ids}"
}

resource "aws_db_parameter_group" "mysql-parameters" {
    name = "mysql-params"
    family = "mysql5.7"
    description = "MysqlDB parameter group"

    parameter {
      name = "max_allowed_packet"
      value = "16777216"
   }

}

resource "aws_db_instance" "mysql-instance" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = "${var.rds_instance_type}"
  identifier           = "mysql"
  name                 = "${var.RDS_DBNAME}"
  username             = "${var.RDS_USERNAME}"   # username
  password             = "${var.RDS_PASSWORD}"
  db_subnet_group_name = "${aws_db_subnet_group.mysql-subnet.name}"
  parameter_group_name = "${aws_db_parameter_group.mysql-parameters.name}"
  multi_az             = "${var.RDS_MULTI_AZ}"
  vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]
  storage_type         = "gp2"
  backup_retention_period = 30
  availability_zone    = "${element(module.hwvpc.private_availability_zones,0) }"
  skip_final_snapshot = true
  final_snapshot_identifier = "mysql-hwdb"
}
