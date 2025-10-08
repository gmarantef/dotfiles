#!/bin/sh
# vim: ft=sh

# Install Homebrew packages if brew is available
if command -v brew >/dev/null 2>&1; then
    echo "› installing Homebrew packages..."
    brew bundle --file="$HOME/.Brewfile"
fi
