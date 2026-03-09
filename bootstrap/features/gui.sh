#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Configuring GUI packages..."

if ! command -v google-chrome >/dev/null 2>&1; then
  log_info "Installing Google Chrome..."
  case "${OS}" in
    Linux)
      wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
      sudo apt install -y ./google-chrome-stable_current_amd64.deb
      rm -f google-chrome-stable_current_amd64.deb
      ;;
    Darwin)
      require_command brew "Run the 'brew' feature first."
      brew install --cask google-chrome
      ;;
    *)
      log_warn "OS not supported for Google Chrome: ${OS}"
      ;;
  esac
  log_info "Google Chrome successfully configured."
else
  log_info "Google Chrome already installed."
fi

log_info "GUI feature completed successfully."
