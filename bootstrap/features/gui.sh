#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Configuring GUI packages..."

install_chrome_linux() {
  local arch
  arch=$(dpkg --print-architecture 2>/dev/null || echo "unknown")
  if [ "${arch}" != "amd64" ]; then
    log_warn "Google Chrome only provides official Linux packages for amd64. Skipping (arch: ${arch})."
    return
  fi

  curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg

  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] \
https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

  sudo apt update
  sudo apt install -y google-chrome-stable
}

if ! command -v google-chrome >/dev/null 2>&1; then
  log_info "Installing Google Chrome..."
  case "${OS}" in
    linux)
      install_chrome_linux
      ;;
    darwin)
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
