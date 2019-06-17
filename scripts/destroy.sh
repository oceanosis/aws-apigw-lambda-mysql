#!/bin/bash
set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR="$(dirname "$SCRIPTDIR")"

cd $BASEDIR/tf_resources
terraform destroy --auto-approve

cd $BASEDIR/tf_init
terraform destroy -force
