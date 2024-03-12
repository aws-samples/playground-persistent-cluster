#!/bin/bash

[[ $1 == "update" ]] && CMD=update-stack || CMD=create-stack

set -euo pipefail

# Fail fast if one LDAP env. var is empty string, but the other LDAP env var is not.
if [[ $SMHP_LDAP_TOKEN_ARN != "" && $SMHP_LDAP_CERT_ARN == "" ]]; then
    echo "
WARNING: one of SMHP_LDAP_TOKEN_ARN or SMHP_LDAP_CERT_ARN is empty. The CloudFormation template
will not attach LDAP permissions to the execution role it creates.
"
    exit -1
elif [[ $SMHP_LDAP_TOKEN_ARN == "" && $SMHP_LDAP_CERT_ARN != "" ]]; then
echo "
WARNING: one of SMHP_LDAP_TOKEN_ARN or SMHP_LDAP_CERT_ARN is empty. The CloudFormation template
will not attach LDAP permissions to the execution role it creates.
"
    exit -1
fi

BIN_DIR=$(dirname $(realpath ${BASH_SOURCE[@]}))
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
