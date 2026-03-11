#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Configuring Homebrew..."

install_basic_plus_flatpak_linux() {
  case "$(get_distro)" in
    ubuntu|debian)
      sudo apt update
      sudo apt install -y build-essential procps curl file git wget flatpak
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
        || log_warn "Could not add flathub remote. Run manually after setup if needed."
      ;;
    fedora)
      sudo dnf group install development-tools
      sudo dnf install -y procps-ng curl file
      ;;
    arch)
      sudo pacman -S --noconfirm base-devel procps-ng curl file git flatpak
      ;;
    *)
      log_error "Linux distro not officially supported for brew: $(get_distro)"
      ;;
  esac
}

install_homebrew() {
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

if command -v brew >/dev/null 2>&1; then
  log_info "Homebrew already installed."
  exit 0
fi

case "${OS}" in
  Linux)
    install_basic_plus_flatpak_linux
    install_homebrew
    ;;
  Darwin)
    install_homebrew
    ;;
  *)
    log_error "OS not supported for brew: ${OS}"
    ;;
esac

log_info "Homebrew successfully configured."
