#!/bin/bash

[[ $1 == "update" ]] && CMD=update-stack || CMD=create-stack

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

AZ_COUNT=$(echo $SMHP_AZ_NAME | awk -F, '{print NF}')

declare ARGS=(
    --region ${SMHP_REGION}
    --stack-name ${SMHP_VPC_STACK_NAME}
    --template-body file://01-smhp-vpc.yaml
    --parameters
        ParameterKey=NumberOfAZs,ParameterValue=${AZ_COUNT}
        ParameterKey=AvailabilityZones,ParameterValue="${SMHP_AZ_NAME}"
        ParameterKey=VPCName,ParameterValue="${SMHP_VPC_NAME}"
        ParameterKey=S3BucketResource,ParameterValue="${SMHP_S3_IAM_RESOURCES}"
        ParameterKey=CreateS3Endpoint,ParameterValue="true"
        ParameterKey=CreateExecutionRole,ParameterValue="${SMHP_CREATE_ROLE}"
        ParameterKey=LdapTokenArn,ParameterValue="${SMHP_LDAP_TOKEN_ARN}"
        ParameterKey=LdapCertArn,ParameterValue="${SMHP_LDAP_CERT_ARN}"
    --capabilities CAPABILITY_IAM
    # --disable-rollback
)

set -x
aws cloudformation $CMD "${ARGS[@]}" | jq .
