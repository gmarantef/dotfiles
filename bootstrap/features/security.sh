#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

echo "Installing security tools..."

install_bitwarden_cli() {
  if command -v brew >/dev/null 2>&1; then
    brew install bitwarden-cli
  else
    echo "brew feature required for bitwarden-cli"
    exit 1
  fi
}

install_bitwarden_gui_linux() {
  if command -v flatpak >/dev/null 2>&1; then
    flatpak install -y flathub com.bitwarden.desktop
  else
    echo "brew feature required for bitwarden GUI"
    exit 1
  fi
}

install_bitwarden_gui_macos() {
  if command -v brew >/dev/null 2>&1; then
    brew install --cask bitwarden
  else
    echo "brew feature required for bitwarden GUI"
    exit 1
  fi
}

# CLI siempre
install_bitwarden_cli

# GUI solo si feature gui activa
if echo "$FEATURES" | grep -q "gui"; then
  case "$OS" in
    Linux)
      install_bitwarden_gui_linux
      ;;
    Darwin)
      install_bitwarden_gui_macos
      ;;
  esac
fi

echo "Bitwarden successfully configured."

echo "Installing jq..."
if command -v brew >/dev/null 2>&1; then
  brew install jq
fi
echo "jq successfully configured."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "security feature completed successfully."