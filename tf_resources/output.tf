output "mysql_endpoint" {
  value = "${aws_db_instance.mysql-instance.address}"
}

output "api_base_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}"
}

output "mysql_dbname" {
  description = "DB name"
  value = "${aws_db_instance.mysql-instance.name}"
}

output "jump_box_ip" {
  value = ["${element(aws_instance.mysql_deploy_box.*.public_ip,0)}"]
}

output "ssh-tunnel" {
  value = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/automation ec2-user@${element(aws_instance.mysql_deploy_box.*.public_ip,0)}"
}

