#!/bin/bash

if [ "$BUILDPLATFORM" == "linux/amd64" ] 
then
    curl -LO https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64 \
    && chmod +x ttyd.x86_64 \
    && mv ttyd.x86_64 /usr/local/bin/ttyd
fi

if [ "$BUILDPLATFORM" == "linux/arm64" ] 
then
    curl -LO https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.arm \
    && chmod +x ttyd.arm \
    && mv ttyd.arm /usr/local/bin/ttyd
fi

which ttyd
mkdir kubeconf
