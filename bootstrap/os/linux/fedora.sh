#!/usr/bin/env sh
set -e

echo "🔧 Preparing Fedora system..."

sudo dnf install -y \
  curl \
  git \
  ca-certificates \
  @development-tools \
  file \
  gnupg2 \
  glibc \
  groff \
  less