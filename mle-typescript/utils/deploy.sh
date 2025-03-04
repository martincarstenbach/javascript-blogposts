#!/usr/bin/bash

set -euxo pipefail

[[ $(basename "$(pwd)") != mle-typescript ]] && {
    echo "ERR: something went wrong changing to the top level directory"
    exit 1
}

/opt/oracle/sqlcl/bin/sql /nolog @utils/deploy