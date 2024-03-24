#!/bin/bash

[[ "$1" == "" ]] && NODE_TYPE=other || NODE_TYPE="$1"

set -exuo pipefail

BIN_DIR=$(dirname $(realpath ${BASH_SOURCE[@]}))
chmod ugo+x $BIN_DIR/initsmhp/*.sh

bash -x $BIN_DIR/initsmhp/disable-gui.sh

declare -a PKGS_SCRIPTS=(
    install-pkgs.sh
    install-delta.sh
    install-duf.sh
    install-s5cmd.sh
    install-tmux.sh
    install-mount-s3.sh
)
mkdir /var/log/initsmhp
for i in "${PKGS_SCRIPTS[@]}"; do
    bash -x $BIN_DIR/initsmhp/$i &> /var/log/initsmhp/$i.txt \
        && echo "SUCCESS: $i" >> /var/log/initsmhp/initsmhp.txt \
        || echo "FAIL: $i" >> /var/log/initsmhp/initsmhp.txt
done

bash -x $BIN_DIR/initsmhp/fix-profile.sh
bash -x $BIN_DIR/initsmhp/ssh-to-compute.sh
bash -x $BIN_DIR/initsmhp/adjust-git.sh
bash -x $BIN_DIR/initsmhp/fix-bash.sh /etc/skel/.bashrc
cp $BIN_DIR/initsmhp/vimrc /etc/skel/.vimrc

# /opt/ml/config/resource_config.json is not world-readable, so take only the part that later-on
# used for ssh-keygen comment.
cat /opt/ml/config/resource_config.json | jq '.ClusterConfig' > /opt/initsmhp-cluster_config.json

if [[ "${NODE_TYPE}" == "controller" ]]; then
    echo "[INFO] This is a Controller node."
    runuser -l ubuntu $BIN_DIR/initsmhp/gen-keypair-ubuntu.sh
    bash -x $BIN_DIR/initsmhp/fix-bash.sh ~ubuntu/.bashrc
    cp $BIN_DIR/initsmhp/vimrc ~ubuntu/.vimrc && chown ubuntu:ubuntu ~ubuntu/.vimrc
    bash -x $BIN_DIR/initsmhp/howto-miniconda.sh
fi

# Placeholder for terminfo. No actual terminfo is setup. Instead, ubuntu user
# must follow https://sw.kovidgoyal.net/kitty/kittens/ssh/ if needed.
/bin/bash -c '
if [[ ! -f ~/.terminfo/x/xterm-kitty ]]; then
    mkdir -p ~/.terminfo/x/
    ln -s ~ubuntu/.terminfo/x/xterm-kitty ~/.terminfo/x/
fi
'
