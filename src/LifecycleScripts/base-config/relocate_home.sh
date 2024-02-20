#!/bin/bash

[[ "$1" == "" ]] && NODE_TYPE=other || NODE_TYPE="$1"

set -exuo pipefail

if [[ "${NODE_TYPE}" == "controller" ]]; then
    echo "[INFO] This is a Controller node."
    usermod -m -d /fsx/ubuntu ubuntu || true
else
    echo "[INFO] This is not a Controller node."
    usermod -d /fsx/ubuntu ubuntu
fi
