#!/bin/bash
yum -y update
yum -y install mysql
echo "mysql --user ${db_username} --host ${db_host} --password${db_password} " > /tmp/ufuk
mysql --user "${db_username}" --host "${db_host}" --password"${db_password}" < mysql.dump