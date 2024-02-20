[[ "${BASH_SOURCE[0]}" == "$0" ]] && {
    echo "You ran ${BASH_SOURCE[0]} which is incorrect usage. You must 'source ${BASH_SOURCE[0]}'" ;
    exit -1 ;
}

# Please review and update below information.
SECRET_MANAGER_ARN=arn:aws:secretsmanager:REGION:111122223333:secret:xxxx
CERT_ARN=arn:aws:acm:REGION:111122223333:certificate/xxxx
LDAP_DEFAULT_BIND_DN=cn=ReadOnlyUser,ou=Users,ou=CORP,dc=corp,dc=example,dc=com
LDAP_SEARCH_BASE=DC=corp,DC=example,DC=com
LDAP_URI=corp.example.com
