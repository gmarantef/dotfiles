#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Installing security tools..."

require_command brew "Run the 'brew' feature first."

install_bitwarden_cli() {
  brew install bitwarden-cli
}

install_bitwarden_gui_linux() {
  if command -v flatpak >/dev/null 2>&1; then
    flatpak install -y flathub com.bitwarden.desktop
  else
    log_warn "flatpak not found. Skipping Bitwarden GUI installation."
  fi
}

install_bitwarden_gui_macos() {
  brew install --cask bitwarden
}

log_info "Installing Bitwarden CLI..."
install_bitwarden_cli

if has_feature "gui"; then
  log_info "Installing Bitwarden GUI..."
  case "${OS}" in
    linux)   install_bitwarden_gui_linux ;;
    darwin)  install_bitwarden_gui_macos ;;
  esac
fi

log_info "Bitwarden successfully configured."

log_info "Installing jq..."
brew install jq
log_info "jq successfully configured."

log_info "Security feature completed successfully."
