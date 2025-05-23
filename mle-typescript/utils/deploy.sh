#!/usr/bin/bash

#
# simulate a CI/CD pipeline by transpiling Typescript to JavaScript
# and load it into the database. Must be done before you invoke
# (SQLcl) project export
#

set -euxo pipefail

# make sure we're in the correct directory
[[ $(basename "$(pwd)") != mle-typescript ]] && {
    echo "ERR: something went wrong changing to the top level directory"
    exit 1
}

# connection details are typically stored in a cloud vault, lacking that
# for this demo an .env file has to suffice. Created it 
if [[ ! -f .env ]]; then
    echo "ERR: .env file missing, create it based on .env.example"
    exit 1
fi

# load username, password and connection string from the .env file
# empty values will be flagged as errors by the script. Incorrect
# values will lead to connection issues
source .env

# simulate the CI pipeline and create the resulting JavaScript
# file in src/javascript as per the 
npm run lint && npm run format && npm run build

# now connect to the database and deploy the transpiled module
sql "${DB_USERNAME}"/"${DB_PASSWORD}"@"${DB_CONNECTSTRING}" <<-EOF

mle create-module -filename src/javascript/todos.js -module-name todos_module -replace

EOF
