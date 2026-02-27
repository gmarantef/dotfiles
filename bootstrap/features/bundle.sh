#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

echo "Installing packages from Brewfile..."

# Check for homebrew into the system
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is needed for bundle installation."
  exit 1
fi

# Packages installation from homebrew bundle
brew bundle --file="$HOME/.Brewfile"

echo "Brewfile packages installed."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "Homebrew bundle feature completed successfully."