# Helloworld App
  - It exposes HTTP-based API by using python lambda scripts with MySQL.
  - Automation of a simple api gateway - lambda - mysql stack with terraform on AWS

# EXPORTs;
```sh
export TF_VAR_AWS_ACCESS_KEY=""
export TF_VAR_AWS_SECRET_KEY=""
export TF_VAR_trusted_ip_range="$(curl http://ifconfig.co)/32"
export TF_VAR_RDS_PASSWORD=""
```
