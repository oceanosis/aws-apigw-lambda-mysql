#!/bin/bash
set -euo pipefail

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASEDIR/tf_resources
terraform destroy --auto-approve

cd $BASEDIR/tf_init
terraform destroy -force
