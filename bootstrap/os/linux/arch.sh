#!/usr/bin/env sh
set -e

echo "🔧 Preparing Arch system..."

sudo pacman -Sy --noconfirm \
  curl \
  git \
  base-devel \
  file \
  gnupg \
  glibc \
  groff \
  less