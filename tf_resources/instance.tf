data "aws_ami" "aws_linux" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn-ami-hvm-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # aws
}
resource "aws_instance" "mysql_deploy_box" {
  ami = "${data.aws_ami.aws_linux.image_id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.mykeypair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.public-sg.id}"]
  subnet_id = "${element(module.hwvpc.public_subnet_ids, 0)}"
  root_block_device {
    volume_size = 8
    volume_type = "standard"
  }
  #user_data = "${file("mysql/mysql.tpl")}"
  user_data = <<-EOT
#!/bin/bash
yum -y update
yum -y install mysql
cat <<MYSQL >/tmp/mysql.dump
CREATE DATABASE IF NOT EXISTS hwdb;
use hwdb;
CREATE TABLE IF NOT EXISTS birthday ( username varchar(20) not null, dateofbirth varchar(20) not null, unixepoch int not null, constraint pk_hw primary key (username) );
/* INSERT INTO birthday ( username,dateofbirth,unixepoch ) VALUES ( 'oceanosis', '26/10/1983',100000000 ); */
MYSQL
mysql -u${var.RDS_USERNAME} -h${aws_db_instance.mysql-instance.address} -p${var.RDS_PASSWORD} < /tmp/mysql.dump >> /tmp/db.log 2>&1
  EOT

  depends_on    = ["aws_db_instance.mysql-instance"]
  tags = {
    Name = "bastion"
    ApplicationName = "jump-box"
  }
}

resource "aws_key_pair" "mykeypair" {
  key_name = "automation"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

/*
data "template_file" "init" {
  template = "${file("mysql/mysql.tpl")}"
  vars = {
     db_host = "${aws_db_instance.mysql-instance.address}"
     db_name = "${aws_db_instance.mysql-instance.name}"
     db_username = "${var.RDS_USERNAME}"
     db_password =" ${var.RDS_PASSWORD}"
  }
}
*/