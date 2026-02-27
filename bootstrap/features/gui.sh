#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

echo "Configuring GUI packages ..."

# Install Google Chrome if not exists
if ! command -v google-chrome >/dev/null 2>&1; then
  echo "Installing Google Chrome ..."
  case "$OS" in
    Linux)
      wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
      sudo apt install -y ./google-chrome-stable_current_amd64.deb
      rm -f google-chrome-stable_current_amd64.deb
      ;;
    Darwin)
      brew install --cask google-chrome
      ;;
    *)
      echo "OS not supported for Google Chrome: $OS"
      exit 0
  esac
fi

echo "Google Chrome successfully configured."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "GUI feature completed successfully."