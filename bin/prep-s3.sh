#!/bin/bash

set -euo pipefail

# Utility function to get script's directory (deal with Mac OSX quirkiness).
# This function is ambidextrous as it works on both Linux and OSX.
get_bin_dir() {
    local READLINK=readlink
    if [[ $(uname) == 'Darwin' ]]; then
        READLINK=greadlink
        if [ $(which greadlink) == '' ]; then
            echo '[ERROR] Mac OSX requires greadlink. Install with "brew install greadlink"' >&2
            exit 1
        fi
    fi

    local BIN_DIR=$(dirname "$($READLINK -f ${BASH_SOURCE[0]})")
    echo -n ${BIN_DIR}
}
BIN_DIR=$(get_bin_dir)
SRC_DIR=$(dirname $BIN_DIR)/src
cd $SRC_DIR

aws s3 sync --delete LifecycleScripts/base-config/ s3://$SMHP_BUCKET/LifecycleScripts/base-config/ --exclude 'provisioning_parameters.json' --exclude 'shared_users_sample.txt'
aws s3 sync lcc-data s3://$SMHP_BUCKET/LifecycleScripts/base-config/
aws s3 ls s3://$SMHP_BUCKET/LifecycleScripts/base-config/
aws s3 cp s3://$SMHP_BUCKET/LifecycleScripts/base-config/provisioning_parameters.json - | jq .
