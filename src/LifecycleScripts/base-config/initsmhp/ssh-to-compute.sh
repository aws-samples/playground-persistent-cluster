#!/bin/bash

set -exuo pipefail

# https://github.com/aws-samples/aws-efa-nccl-baseami-pipeline/blob/9d8a9273f72d7dee36f7f3e5e8a968b5e0f5f21b/nvidia-efa-ami_base/nvidia-efa-ml-ubuntu2004.yml#L163-L169
cat << EOF >> /etc/ssh/ssh_config
    StrictHostKeyChecking no
    HostbasedAuthentication no
    CheckHostIP no
    UserKnownHostsFile /dev/null
EOF
