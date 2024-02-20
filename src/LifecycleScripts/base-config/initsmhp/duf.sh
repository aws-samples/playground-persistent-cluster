#!/bin/bash

set -exuo pipefail

# Constants
APP=duf
GH=muesli/duf

latest_download_url() {
  [[ $(uname -i) == "x86_64" ]] && local arch=amd64 || local arch=arm64
  curl --silent "https://api.github.com/repos/${GH}/releases/latest" |   # Get latest release from GitHub api
    grep "\"browser_download_url\": \"https.*\/duf_.*_linux_$arch.deb" |  # Get download url
    sed -E 's/.*"([^"]+)".*/\1/'                                         # Pluck JSON value
}

LATEST_DOWNLOAD_URL=$(latest_download_url)
DEB=${LATEST_DOWNLOAD_URL##*/}
(cd /tmp/ && curl -LO ${LATEST_DOWNLOAD_URL})

sudo apt install -y /tmp/$DEB && rm /tmp/$DEB
