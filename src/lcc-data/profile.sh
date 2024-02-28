################################################################################
# 000: Please review and update below information.
################################################################################
# These two must be in tandem. Either they're all empty string, or all must set to ARN
export SMHP_LDAP_TOKEN_ARN=arn:aws:secretsmanager:REGION:111122223333:secret:xxxx
export SMHP_LDAP_CERT_ARN=arn:aws:acm:REGION:111122223333:certificate/xxxx

export SMHP_LDAP_DEFAULT_BIND_DN=cn=ReadOnlyUser,ou=Users,ou=CORP,dc=corp,dc=example,dc=com
export SMHP_LDAP_SEARCH_BASE=DC=corp,DC=example,DC=com
export SMHP_LDAP_URI=corp.example.com


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
