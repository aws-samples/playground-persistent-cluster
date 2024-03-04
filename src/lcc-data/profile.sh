################################################################################
# 000: Please review and update below information.
################################################################################
# These two must be in tandem. Either they're all empty string, or all must set to ARN
export SMHP_LDAP_TOKEN_ARN=arn:aws:secretsmanager:REGION:111122223333:secret:xxxx
export SMHP_LDAP_CERT_ARN=arn:aws:acm:REGION:111122223333:certificate/xxxx

export SMHP_LDAP_DEFAULT_BIND_DN=cn=ReadOnlyUser,ou=Users,ou=CORP,dc=corp,dc=example,dc=com
export SMHP_LDAP_SEARCH_BASE=DC=corp,DC=example,DC=com
export SMHP_LDAP_URI=corp.example.com

export SMHP_AMP_REMOTE_WRITE_URL=https://aps-workspaces.REGION.amazonaws.com/workspaces/ws-xxxx/api/v1/remote_write
