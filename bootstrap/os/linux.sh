#!/usr/bin/env sh
set -e

echo "🔎 Detecting Linux distribution..."

if [ -f /etc/os-release ]; then
  . /etc/os-release
else
  echo "Cannot detect Linux distribution"
  exit 1
fi

case "$ID" in
  ubuntu|debian)
    sh bootstrap/os/linux/ubuntu.sh
    ;;
  fedora)
    sh bootstrap/os/linux/fedora.sh
    ;;
  arch)
    sh bootstrap/os/linux/arch.sh
    ;;
  *)
    echo "Unsupported Linux distribution: $ID"
    exit 1
    ;;
esac