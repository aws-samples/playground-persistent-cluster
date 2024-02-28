#!/bin/bash

set -euo pipefail

####################################################################################################
# Pre-requisites:
#
# - an pre-existing LDAPS endpoint. Setting the LDAPS is beyond the scope of this script, but feel
#   free to how AWS ParallelCluster set this up:
#   https://docs.aws.amazon.com/parallelcluster/latest/ug/tutorials_05_multi-user-ad.html
#
# - the read-only credential to LDAPS in AWS Secret Manager
# - the LDAPS certificate in AWS Certificate Manager
####################################################################################################

# No `set -x` to prevent ro credential appear in logs.
# As a extra precautionary measure, the next line is in case someone do a `bash -x <THIS_SCRIPT>`.
set +x

source ./profile.sh

[[ $SMHP_LDAP_CERT_ARN == "" && $SMHP_LDAP_TOKEN_ARN == "" ]] \
    && { echo "Skip sssd setup because both SMHP_LDAP_CERT_ARN and SMHP_LDAP_TOKEN_ARN are blanks." ; exit 0 ; } \
    || true

[[ $SMHP_LDAP_CERT_ARN == "" || $SMHP_LDAP_TOKEN_ARN == "" ]] \
    && { echo "Error: one of SMHP_LDAP_CERT_ARN or SMHP_LDAP_TOKEN_ARN is blank." ; exit -1 ; } \
    || true

: "${SMHP_LDAP_DEFAULT_BIND_DN:=cn=ReadOnlyUser,ou=Users,ou=CORP,dc=corp,dc=example,dc=com}"
: "${SMHP_LDAP_SEARCH_BASE:=DC=corp,DC=example,DC=com}"
: "${SMHP_LDAP_URI:=corp.example.com}"

# Increase max retries, in case the default is still insufficient to handle API throttle in a large cluster.
# Each `aws cli` makes at most (1 + AWS_MAX_ATTEMPTS) requests.
export AWS_RETRY_MODE=adaptive
export AWS_MAX_ATTEMPTS=7

REGION=$(echo $SMHP_LDAP_TOKEN_ARN | cut -d':' -f4)
LDAP_DEFAULT_AUTHTOK=$(aws secretsmanager get-secret-value \
    --secret-id ${SMHP_LDAP_TOKEN_ARN} \
    --region $REGION \
    | jq -r '.SecretString'
)

apt-get -y -o DPkg::Lock::Timeout=120 update
apt-get install -y sssd
cat << EOF > /etc/sssd/sssd.conf
[domain/default]
cache_credentials = True
default_shell = /bin/bash
fallback_homedir = /fsx/home/%u
id_provider = ldap
ldap_default_authtok = ${LDAP_DEFAULT_AUTHTOK}
ldap_default_bind_dn = ${SMHP_LDAP_DEFAULT_BIND_DN}
ldap_id_mapping = True
ldap_referrals = False
ldap_schema = AD
ldap_search_base = ${SMHP_LDAP_SEARCH_BASE}
ldap_tls_cacert = /opt/domain-certificate.crt
ldap_tls_reqcert = hard
ldap_uri = ldaps://${SMHP_LDAP_URI}
use_fully_qualified_names = False

[domain/local]
id_provider = files
enumerate = True

[sssd]
config_file_version = 2
services = nss, pam, ssh
domains = default, local
full_name_format = %1\$s

[nss]
filter_users = nobody,root,ubuntu
filter_groups = nobody,root,ubuntu

[pam]
offline_credentials_expiration = 7
EOF

# SSSD refuses to start with world-readable config file.
chmod 600 /etc/sssd/sssd.conf

aws acm --region $REGION get-certificate \
    --certificate-arn ${SMHP_LDAP_CERT_ARN} | jq -r '.Certificate' > /opt/domain-certificate.crt
systemctl enable --now sssd.service
pam-auth-update --enable mkhomedir
