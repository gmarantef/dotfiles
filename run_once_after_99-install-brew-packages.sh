#!/bin/sh
# vim: ft=sh
set -e

# Sudo at start
echo "request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install flatpak for packages inside brew bundle
if ! command -v flatpak >/dev/null 2>&1: then
    echo "installing fltapak ..."
    sudo apt update
    sudo apt install -y flatpak
fi

# Add flathub repository
if ! flatpak remote-list | grep -q flathub; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Homebrew packages if brew is available
if command -v brew >/dev/null 2>&1; then
    echo "installing Homebrew packages..."
    brew bundle --file="$HOME/.Brewfile"
fi
