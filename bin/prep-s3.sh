#!/bin/bash

set -euo pipefail

BIN_DIR=$(dirname $(realpath ${BASH_SOURCE[@]}))
SRC_DIR=$(dirname $BIN_DIR)/src
cd $SRC_DIR

aws s3 sync --delete LifecycleScripts/base-config/ s3://$SMHP_BUCKET/LifecycleScripts/base-config/ --exclude 'provisioning_parameters.json' --exclude 'shared_users_sample.txt'
aws s3 sync lcc-data s3://$SMHP_BUCKET/LifecycleScripts/base-config/
aws s3 ls s3://$SMHP_BUCKET/LifecycleScripts/base-config/
aws s3 cp s3://$SMHP_BUCKET/LifecycleScripts/base-config/provisioning_parameters.json - | jq .
