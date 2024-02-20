[[ "${BASH_SOURCE[0]}" == "$0" ]] && { echo "You must source this script" 2>&1 ; exit -1 ; }


################################################################################
# 000: Please review and update below information.
################################################################################
export SMHP_REGION=us-west-2
export SMHP_VPC_STACK_NAME=vpc-smhp-xxxx
export SMHP_VPC_NAME="SMHP VPC"
export SMHP_AZ_NAME=us-west-2a\\,us-west-2b
export SMHP_CREATE_ROLE=true
export SMHP_BUCKET=smhp-xxxx
export SMHP_S3_IAM_RESOURCES="arn:aws:s3:::${SMHP_BUCKET}"

# These two must be in tandem. Either they're all empty string, or all must set to ARN
export SMHP_LDAP_TOKEN_ARN="arn:aws:secretsmanager:REGION:111122223333:secret:xxxx"
export SMHP_LDAP_CERT_ARN="arn:aws:acm:REGION:111122223333:certificate/xxxx"


################################################################################
# 010: Stuffs that should not be modified.
################################################################################
# Friendly warning if one LDAP env. var is empty string, but the other LDAP env var is not.
if [[ $SMHP_LDAP_TOKEN_ARN != "" && $SMHP_LDAP_CERT_ARN == "" ]]; then
    echo "
WARNING: one of SMHP_LDAP_TOKEN_ARN or SMHP_LDAP_CERT_ARN is empty. The CloudFormation template
will not attach LDAP permissions to the execution role it creates.
"
elif [[ $SMHP_LDAP_TOKEN_ARN == "" && $SMHP_LDAP_CERT_ARN != "" ]]; then
echo "
WARNING: one of SMHP_LDAP_TOKEN_ARN or SMHP_LDAP_CERT_ARN is empty. The CloudFormation template
will not attach LDAP permissions to the execution role it creates.
"
fi
