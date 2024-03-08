################################################################################
# -010: quality-of-life: warn when overriding an existing profile
################################################################################
env | grep ^SMHP &> /dev/null && echo "Will override existing profile..."


################################################################################
# 000: Review and update: (i) below variables, and (ii) src/lcc-data/profile.sh
################################################################################
export SMHP_REGION=us-west-2
export SMHP_VPC_STACK_NAME=vpc-smhp-xxxx
export SMHP_VPC_NAME="SMHP VPC"
export SMHP_AZ_NAME=us-west-2a\\,us-west-2b
export SMHP_CREATE_ROLE=true
export SMHP_BUCKET=smhp-xxxx
export SMHP_S3_IAM_RESOURCES="arn:aws:s3:::${SMHP_BUCKET}"

source src/lcc-data/profile.sh


################################################################################
# 010: quality-of-life
################################################################################
[[ $(echo $PATH | awk -F'[=:]' '{print $1}') == $(pwd)/bin ]] \
    || { export PATH=$(pwd)/bin:$PATH ; echo "Set PATH=$(pwd)/bin:\$PATH" ; }

echo "SMHP profile has been loaded. See env vars with 'check-profile.sh' command."
