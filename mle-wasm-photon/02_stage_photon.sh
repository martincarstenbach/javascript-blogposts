#!/usr/bin/env bash

set -euo pipefail

if [ "$(basename $(pwd))" != mle-wasm-photon ]; then
    echo ERR: must run this in javascript-blogposts/mle-wasm-photon
    exit 1
fi

for dir in stage logs tns; do
    [[ ! -d ${dir} ]] && mkdir -vp ${dir}
done

# get photon 0.3.3 from JSDelivr and stage it

curl --fail --show-error --location -L https://cdn.jsdelivr.net/npm/@silvia-odwyer/photon@0.3.3/photon_rs.js -o stage/photon_rs.js
curl --fail --show-error --location -L https://cdn.jsdelivr.net/npm/@silvia-odwyer/photon@0.3.3/photon_rs_bg.wasm -o stage/photon_rs_bg.wasm

# load photon into the database
[[ -f .env ]] || {
    echo ERR: prepare an .env file in this directory. Use env.example as your source
    exit 1
}

source .env

sqlldr userid="${ORACLE_USERNAME}/${ORACLE_PASSWORD}@${ORACLE_CONNECTIONSTRING}" \
  control=load_photon.ctl \
  log=logs/$(date +%Y%m%d_%H%M%S)_load_photon.log \
  direct=false