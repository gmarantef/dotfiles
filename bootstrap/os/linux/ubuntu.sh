#!/usr/bin/env sh
set -e

echo "🔧 Preparing Ubuntu/Debian system..."

sudo apt update
sudo apt install -y \
  curl \
  git \
  ca-certificates \
  build-essential \
  file \
  gnupg \
  glibc \
  groff \
  less