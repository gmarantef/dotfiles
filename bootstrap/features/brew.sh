#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

echo "Configuring Homebrew..."

install_basic_plus_flatpak_linux() {
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      sudo apt update
      sudo apt install -y build-essential procps curl file git wget flatpak
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      ;;
    fedora)
      sudo dnf group install development-tools
      sudo dnf install procps-ng curl file
      ;;
    arch)
      sudo pacman -S base-devel procps-ng curl file git flatpak
      ;;
    *)
      echo "Linux distro not officially supported for brew: $ID"
      exit 1
      ;;
  esac
}

install_homebrew() {
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Check for homebrew into the system
if command -v brew >/dev/null 2>&1; then
  echo "Homebrew already installed"
  exit 0
fi

# Homebrew installation
case "$OS" in
  Linux)
    install_basic_plus_flatpak_linux
    install_homebrew
    ;;
  Darwin)
    install_homebrew
    ;;
  *)
    echo "OS not supported for brew: $OS"
    exit 1
    ;;
esac

echo "Homebrew successfully configured."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "Brew feature completed successfully."