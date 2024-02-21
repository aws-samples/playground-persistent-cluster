#!/bin/bash

set -euo pipefail
echo "${BASH_SOURCE[0]}" runs on $(hostname)
dcgmi test --inject --gpuid 0 -f 202 -v 99999
sleep 1
dcgmi test --inject --gpuid 0 -f 319 -v 4
sleep 1
