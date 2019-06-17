# Helloworld API Gateway - Python Lambda Functions - RDS MySQL DB
  - Serverless Structure
  - It exposes HTTP-based API triggering lambda python scripts.
  - Push data to MySQL / Get data from MySQL 
  - Automation of "HelloWorld" api gateway - lambda - mysql stack with terraform on AWS

### Requirements
  - username must be {proxy} parameter such as api/prod/hello/{ufuk}
  - dateOfBirth format: "YYYY-MM-DD" for PUT requests
  - username must contain only letters
  - dateOfBirth must be a date before today
  - and GET birthday response messages and calculations

# Design
[![aws design](https://github.com/oceanosis/aws-apigw-lambda-mysql/blob/master/docs/aws.png)](https://github.com/oceanosis/aws-apigw-lambda-mysql/blob/master/docs/aws.png)

## Configure AWS creds
```sh
$ aws configure
   AWS Access Key ID [None]: accesskey
   AWS Secret Access Key [None]: secretkey
   Default region name [None]: us-west-2
   Default output format [None]:
```

## Export the following terraform variables
```sh
export TF_VAR_AWS_ACCESS_KEY="accesskey"
export TF_VAR_AWS_SECRET_KEY="secretkey"
export TF_VAR_AWS_REGION="eu-west-2"
export TF_VAR_trusted_ip_range="$(curl http://ifconfig.co)/32"  # Or give your trusted IP range
export TF_VAR_RDS_USERNAME="root"
export TF_VAR_RDS_PASSWORD="password"
export TF_VAR_RDS_DBNAME="hwdb"
export TF_VAR_RDS_MULTI_AZ="true"          # Change it to 'false' to have single db host...
export TF_VAR_PATH_TO_PUBLIC_KEY="$HOME/.ssh/automation.pub"
export TF_VAR_PATH_TO_PRIVATE_KEY="$HOME/.ssh/automation"
```

## Deploy all resources
```sh
make help
make deploy
```

## Deploy lambda changes
```sh
make lambda_deploy
```

## Test API with different user and date options
```sh
make put_test API_URL=????.execute-api.eu-west-2.amazonaws.com USER=ufukd DATE=1983-01-01
make get_test API_URL=????.execute-api.eu-west-2.amazonaws.com USER=ufukd
```

## Destroy all resources
```sh
make destroy
```

---

### TEST API
```sh
# PUT TEST
# test with todays date
curl -vvv -X PUT https://??????.execute-api.eu-west-2.amazonaws.com/prod/hello/ufukd?dateOfBirth=2000-06-17
# test with a future date
curl -vvv -X PUT https://??????.execute-api.eu-west-2.amazonaws.com/prod/hello/ufukd?dateOfBirth=2020-06-17

# GET TEST
curl -vvv https://????????.execute-api.eu-west-2.amazonaws.com/prod/hello/ufukd
```

### TEST LAMBDA
```sh
aws lambda invoke --function-name put_helloworld \
--invocation-type RequestResponse --payload file://test/lambda_put.json put_response.txt

aws lambda invoke --function-name get_helloworld \
--invocation-type RequestResponse --payload file://test/lambda_get.json get_response.txt
```

### Todos

 - Write MORE Tests
 - Add WAF (more security)

License
----

MIT
