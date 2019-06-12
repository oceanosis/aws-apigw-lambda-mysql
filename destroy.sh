#!/bin/bash

unset ANSIBLE_CONFIG

export BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASEDIR/tf_resources
terraform destroy --auto-approve

cd $BASEDIR/tf_init
terraform destroy -force
