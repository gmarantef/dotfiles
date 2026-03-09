#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_step "Configuring shell..."

if [ -z "${DEFAULT_SHELL}" ]; then
  log_warn "No default shell defined, skipping."
  exit 0
fi

case "${DEFAULT_SHELL}" in
  zsh)
    . "$(dirname "$0")/shell/zsh.sh"
    ;;
  *)
    log_warn "Unknown shell '${DEFAULT_SHELL}', skipping."
    ;;
esac

log_info "Shell feature completed successfully."
