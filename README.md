# Helloworld App
  - It exposes HTTP-based API by using python lambda scripts with MySQL.
  - Automation of a simple api gateway - lambda - mysql stack with terraform on AWS

# EXPORTs;
```sh
export TF_VAR_AWS_ACCESS_KEY=""
export TF_VAR_AWS_SECRET_KEY=""
export TF_VAR_trusted_ip_range="$(curl http://ifconfig.co)/32"
export TF_VAR_RDS_USERNAME="root"
export TF_VAR_RDS_PASSWORD="password"
export TF_VAR_RDS_DBNAME="hwdb"
export TF_VAR_RDS_MULTI_AZ="false" # Change it to 'true' to have HA...
export TF_VAR_PATH_TO_PUBLIC_KEY="$HOME/.ssh/automation.pub"
export TF_VAR_PATH_TO_PRIVATE_KEY="$HOME/.ssh/automation"
```

# Run deployment (pipeline)
```sh
make deploy
make lambda_deploy
make destroy
make destroy_all
make test API_URL={{ API URL }}
```

# TEST API
```sh
curl -vvv -X PUT https://{{ API URL }}/prod/hello/username?dateOfBirth=2018-01-01

curl -vvv -X GET https://{{ API URL }}/prod/hello/username
```

# TEST LAMBDA
```sh
aws lambda invoke --function-name put_helloworld \
--invocation-type RequestResponse --payload file://test/lambda_put.json put_response.txt

aws lambda invoke --function-name get_helloworld \
--invocation-type RequestResponse --payload file://test/lambda_get.json get_response.txt
```
