#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_step "Preparing macOS base system..."

MACOS_VERSION="$(sw_vers -productVersion)"
export MACOS_VERSION
log_info "macOS version: ${MACOS_VERSION}"

if ! xcode-select -p >/dev/null 2>&1; then
  log_warn "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
  log_error "Please complete the Xcode CLT installation and re-run bootstrap."
fi

for cmd in curl git; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    log_error "Missing required tool '${cmd}'. Ensure Xcode CLT is properly installed."
  fi
done

log_info "macOS base ready."
