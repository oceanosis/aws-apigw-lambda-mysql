#!/bin/bash

unset ANSIBLE_CONFIG

export BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASEDIR/tf_init
terraform init
terraform plan -out tf_init.out
terraform apply tf_init.out

cd $BASEDIR/lambda_py
# zipping lambda rds confing without mysql connection
zip put_helloworld.zip lambda_put_handler.py rds_config.py
zip get_helloworld.zip lambda_get_handler.py rds_config.py

cd $BASEDIR/tf_resources
terraform init
terraform plan -out tf_res.out
terraform apply tf_res.out

RDS_ENDPOINT=$(terraform output -json | jq ".mysql_endpoint.value" -r | cut -d':' -f1)

cat > $BASEDIR/lambda_py/rds_config.py << EOL
db_host = "$RDS_ENDPOINT"
db_username = "$TF_VAR_RDS_USERNAME"
db_password = "$TF_VAR_RDS_PASSWORD"
db_name = "$TF_VAR_RDS_DBNAME"
EOL

cd $BASEDIR/lambda_py
# push python rds config
zip put_helloworld.zip lambda_put_handler.py rds_config.py
zip get_helloworld.zip lambda_get_handler.py rds_config.py
aws lambda update-function-code --function-name put_helloworld --zip-file fileb://put_helloworld.zip
aws lambda update-function-code --function-name get_helloworld --zip-file fileb://get_helloworld.zip


