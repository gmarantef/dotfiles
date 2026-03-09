#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Installing packages from Brewfile..."

require_command brew "Run the 'brew' feature first."

brew bundle --file="${HOME}/.Brewfile"

log_info "Brewfile packages installed."
log_info "Bundle feature completed successfully."
