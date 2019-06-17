#!/bin/bash
set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR="$(dirname "$SCRIPTDIR")"

cd $BASEDIR/lambda_py/lambda_put
# push python rds config
zip -g ../put_helloworld.zip lambda_put.py rds_config.py

cd $BASEDIR/lambda_py/lambda_get
zip -g ../get_helloworld.zip lambda_get.py rds_config.py

cd $BASEDIR/lambda_py
aws lambda update-function-code --function-name put_helloworld --zip-file fileb://put_helloworld.zip
aws lambda update-function-code --function-name get_helloworld --zip-file fileb://get_helloworld.zip