#!/bin/bash

set -exuo pipefail

# Constants
APP=s5cmd
GH=peak/s5cmd

#DEST_DIR=~/.local/bin
DEST_DIR=/usr/local/bin/
mkdir -p $DEST_DIR
cd $DEST_DIR

latest_download_url() {
  [[ $(uname -i) == "x86_64" ]] && local goarch=64bit || local goarch=arm64
  curl --silent "https://api.github.com/repos/${GH}/releases/latest" |   # Get latest release from GitHub api
    grep "\"browser_download_url\": \"https.*$(uname)-$goarch.tar.gz" |  # Get download url
    sed -E 's/.*"([^"]+)".*/\1/'                                         # Pluck JSON value
}


LATEST_DOWNLOAD_URL=$(latest_download_url)
TARBALL=${LATEST_DOWNLOAD_URL##*/}
curl -LO ${LATEST_DOWNLOAD_URL}

# Go tarball has no root, so we need to create one
DIR=${TARBALL%.tar.gz}
mkdir -p $DIR && cd $DIR && tar -xzf ../$TARBALL && cd .. && rm $TARBALL

[[ -L ${APP}-latest ]] && rm ${APP}-latest
ln -s $DIR ${APP}-latest
ln -s ${APP}-latest/${APP} . || true
