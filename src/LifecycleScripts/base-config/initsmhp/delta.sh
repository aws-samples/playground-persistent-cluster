#!/bin/bash

set -exuo pipefail

# Constants
APP=delta
GH=dandavison/delta

#DEST_DIR=~/.local/bin
DEST_DIR=/usr/local/bin
mkdir -p $DEST_DIR
cd $DEST_DIR

latest_download_url() {
  curl --silent "https://api.github.com/repos/${GH}/releases/latest" |   # Get latest release from GitHub api
    grep "\"browser_download_url\": \"https.*\/delta-.*-$(uname -i)-unknown-linux-musl.tar.gz" |  # Get download url
    sed -E 's/.*"([^"]+)".*/\1/'                                         # Pluck JSON value
}


LATEST_DOWNLOAD_URL=$(latest_download_url)
TARBALL=${LATEST_DOWNLOAD_URL##*/}
curl -LO ${LATEST_DOWNLOAD_URL}

# Go tarball has no root, so we need to create one
DIR=${TARBALL%.tar.gz}
tar -xzf $TARBALL && rm $TARBALL

[[ -L ${APP}-latest ]] && rm ${APP}-latest
ln -s $DIR ${APP}-latest
ln -s ${APP}-latest/${APP} . || true
