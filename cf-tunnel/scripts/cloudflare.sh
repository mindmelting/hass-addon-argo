#!/usr/bin/env bash

declare -A arch=(["aarch64"]="amd64" ["amd64"]="amd64" ["armhf"]="arm" ["armv7"]="arm" ["i386"]="386")

mkdir -p /opt/cloudflare
curl -sSLf -o /opt/cloudflare/cloudflared https://github.com/cloudflare/cloudflared/releases/download/2021.11.0/cloudflared-linux-"${arch[${BUILD_ARCH}]}"
chmod +x /opt/cloudflare/cloudflared
