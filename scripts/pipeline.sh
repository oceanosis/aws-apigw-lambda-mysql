#!/bin/bash
set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR="$(dirname "$SCRIPTDIR")"


cd $BASEDIR/tf_init
terraform init
terraform plan -out tf_init.out
terraform apply tf_init.out

cd $BASEDIR/tf_resources
if [ ! -f $HOME/.ssh/automation ]; then
ssh-keygen -t rsa -f $HOME/.ssh/automation -N ''
fi
terraform init
terraform plan -out tf_res.out
terraform apply tf_res.out

export RDS_ENDPOINT=$(terraform output -json | jq ".mysql_endpoint.value" -r)

cat > $BASEDIR/lambda_py/rds_config.py << EOL
db_host = "$RDS_ENDPOINT"
db_username = "$TF_VAR_RDS_USERNAME"
db_password = "$TF_VAR_RDS_PASSWORD"
db_name = "$TF_VAR_RDS_DBNAME"
EOL




