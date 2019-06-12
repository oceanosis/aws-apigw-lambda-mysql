#!/bin/bash

unset ANSIBLE_CONFIG

export BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASEDIR/tf_init
terraform init
terraform plan -out tf_init.out
terraform apply tf_init.out

cd $BASEDIR/tf_resources
terraform init
terraform plan -out tf_res.out
terraform apply tf_res.out
MYSQL_ENDPOINT=$(terraform output -json | jq ".mysql_endpoint.value" -r)
