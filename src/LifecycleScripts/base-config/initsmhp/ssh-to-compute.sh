#!/bin/bash

set -exuo pipefail

# https://github.com/aws-samples/aws-efa-nccl-baseami-pipeline/blob/9d8a9273f72d7dee36f7f3e5e8a968b5e0f5f21b/nvidia-efa-ami_base/nvidia-efa-ml-ubuntu2004.yml#L163-L169

if [[ -f /var/spool/slurmd/conf-cache/slurm.conf ]]; then
    SLURM_CONFIG=/var/spool/slurmd/conf-cache/slurm.conf
elif [[ -f /opt/slurm/etc/slurm.conf ]]; then
    SLURM_CONFIG=/opt/slurm/etc/slurm.conf
else
    echo slurm.conf not found.
    exit 0
fi

HOSTNAME=$(hostname)
cat << EOF >> /etc/ssh/ssh_config.d/initsmhp-ssh.conf
Host 127.0.0.1 localhost $HOSTNAME
    StrictHostKeyChecking no
    HostbasedAuthentication no
    CheckHostIP no
    UserKnownHostsFile /dev/null

Match host * exec "grep '^NodeName=%h ' $SLURM_CONFIG &> /dev/null"
    StrictHostKeyChecking no
    HostbasedAuthentication no
    CheckHostIP no
    UserKnownHostsFile /dev/null
EOF
