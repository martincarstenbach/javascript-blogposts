#!/usr/bin/bash

set -euxo pipefail

cd dist || {
    echo ERR: cannot change to dist directory. Run npm run deploy first!
    exit 1
}

cat <<EOF > deploy.sql

conn -n demouser

mle create-module -filename todos.js -module-name todos_module -replace

create or replace mle env todos_env imports (
    'todos' module todos_module
);
exit
EOF

/opt/oracle/sqlcl/bin/sql /nolog @deploy.sql