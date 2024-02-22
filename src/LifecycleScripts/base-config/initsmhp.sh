#!/bin/bash

[[ "$1" == "" ]] && NODE_TYPE=other || NODE_TYPE="$1"

set -exuo pipefail

BIN_DIR=$(dirname $(readlink -e ${BASH_SOURCE[0]}))
chmod ugo+x $BIN_DIR/initsmhp/*.sh

bash -x $BIN_DIR/initsmhp/setup-timesync.sh
bash -x $BIN_DIR/initsmhp/pkgs.sh
bash -x $BIN_DIR/initsmhp/delta.sh
bash -x $BIN_DIR/initsmhp/duf.sh
bash -x $BIN_DIR/initsmhp/s5cmd.sh
bash -x $BIN_DIR/initsmhp/tmux.sh
bash -x $BIN_DIR/initsmhp/fix-profile.sh
bash -x $BIN_DIR/initsmhp/ssh-to-compute.sh
bash -x $BIN_DIR/initsmhp/adjust-git.sh
bash -x $BIN_DIR/initsmhp/fix-bash.sh /etc/skel/.bashrc

# /opt/ml/config/resource_config.json is not world-readable, so take only the part that later-on
# used for ssh-keygen comment.
cat /opt/ml/config/resource_config.json | jq '.ClusterConfig' > /opt/initsmhp-cluster_config.json

if [[ "${NODE_TYPE}" == "controller" ]]; then
    echo "[INFO] This is a Controller node."
    runuser -l ubuntu $BIN_DIR/initsmhp/gen-keypair-ubuntu.sh
    bash -x $BIN_DIR/initsmhp/fix-bash.sh ~ubuntu/.bashrc
    bash -x $BIN_DIR/initsmhp/howto-miniconda.sh
fi
