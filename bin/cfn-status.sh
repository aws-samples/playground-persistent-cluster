#!/bin/bash

set -euo pipefail

set -x
aws cloudformation describe-stacks --stack-name "$SMHP_VPC_STACK_NAME" | jq .
