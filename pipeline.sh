#!/bin/bash
set -euo pipefail

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASEDIR/tf_init
terraform init
terraform plan -out tf_init.out
terraform apply tf_init.out

cd $BASEDIR/lambda_py
# zipping lambda rds confing without mysql connection
zip -g put_helloworld.zip lambda_put.py rds_config.py
zip -g get_helloworld.zip lambda_get.py rds_config.py

cd $BASEDIR/tf_resources
if [ ! -f $HOME/.ssh/automation ]; then
ssh-keygen -t rsa -f $HOME/.ssh/automation -N ''
fi
terraform init
terraform plan -out tf_res.out
terraform apply tf_res.out

RDS_ENDPOINT=$(terraform output -json | jq ".mysql_endpoint.value" -r)

cat > $BASEDIR/lambda_py/rds_config.py << EOL
db_host = "$RDS_ENDPOINT"
db_username = "$TF_VAR_RDS_USERNAME"
db_password = "$TF_VAR_RDS_PASSWORD"
db_name = "$TF_VAR_RDS_DBNAME"
EOL

cd $BASEDIR/lambda_py
# push python rds config
zip -g put_helloworld.zip lambda_put.py rds_config.py
zip -g get_helloworld.zip lambda_get.py rds_config.py
aws lambda update-function-code --function-name put_helloworld --zip-file fileb://put_helloworld.zip
aws lambda update-function-code --function-name get_helloworld --zip-file fileb://get_helloworld.zip


