#!/usr/bin/env bash

set -euxo pipefail

# Update all NPM packages used in a project.
#
# - sets all version numbers to "*"
# - runs npm update --save to bump version numbers to the latest available
#
# Tested with note 20/LTS (iron) and npm 10.8.2 on Linux Mint 22/x86-64
#
# Parameters
# - package.json: the package.json you want to modify
#
# Requires:
# - jq
#
# ONLY TO BE USED INTERNALLY - DO NOT USE THIS SCRIPT. IT HAS NOT UNDERGONE
# RIGOROUS TESTING AT ALL. THINGS MAY BRAKE

[[ ! -f ${1:-"doesnotexist"} ]] && {
    echo "usage: ${0} <package.json>"
    exit 1
}

FULL_PATH="${1}"
DIR=$(dirname "${FULL_PATH}")
FILE=$(basename "${FULL_PATH}")

cd "${DIR}" || {
    echo "ERR: cannot change to ${DIR}", exiting
    exit 1
}

# shellcheck disable=SC2002
cat "${FILE}" | jq 'walk(if type == "string" and test("^\\^+") then "*" else . end)'

read -rp "Are you ok to use the above package.json? Choose y to perform the update in ${DIR}? [y/N] " answer
[[ ${answer} != y ]] && exit 0

TS=$(date +%C%m%d_%H%M%S)
cp "${FILE}" "${FILE}_${TS}" || {
    echo "ERR: cannot create a backup of the existing package.json in ${DIR}, exiting"
    exit 1
}

jq 'walk(if type == "string" and test("^\\^+") then "*" else . end)' "${FILE}"
npm update --save