#!/bin/bash

set -exuo pipefail

cd /tmp

get_latest_release() {
  curl --silent "https://api.github.com/repos/tmux/tmux/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

get_latest_download() {
  curl --silent "https://api.github.com/repos/tmux/tmux/releases/latest" | # Get latest release from GitHub api
    grep '"browser_download_url":' |                                # Get download url
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
curl -LO $(get_latest_download)

VERSION=$(get_latest_release)
sudo apt install -y libevent-dev ncurses-dev gcc make bison pkg-config
tar -xzf tmux-$VERSION.tar.gz
cd tmux-$VERSION/
./configure &> /tmp/tmux-00-configure.txt
make &> /tmp/tmux-01-make.txt && sudo make install &> /tmp/tmux-02-make-install.txt
make clean &> /tmp/tmux-03-make-clean.txt
cd /tmp/
rm /tmp/tmux-$VERSION.tar.gz
rm -fr /tmp/tmux-$VERSION/
