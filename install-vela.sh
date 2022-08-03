#!/bin/bash

VERSION=${VERSION:-"v1.5.0-beta.6"}

if [ "$VERSION" == "latest" ]
then
  VERSION="v1.5.0-beta.6"
fi

PLATFORM=linux-amd64

if [ "$BUILDPLATFORM" == "linux/arm64" ] 
then
    PLATFORM=linux-arm64
fi
echo "Download the binary from: https://github.com/kubevela/kubevela/releases/download/$VERSION/vela-$VERSION-$PLATFORM.tar.gz"

curl -LO https://github.com/kubevela/kubevela/releases/download/$VERSION/vela-$VERSION-$PLATFORM.tar.gz
if [ ! -d "vela" ]; then
  mkdir -p vela
fi

tar -zxf vela-$VERSION-$PLATFORM.tar.gz -C vela || exit 1
mv vela/linux-amd64/vela /usr/local/bin/vela || exit 1
rm vela-$VERSION-$PLATFORM.tar.gz 
rm -r vela
vela version
