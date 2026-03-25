#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_step "Installing Claude Code..."

if command -v claude >/dev/null 2>&1; then
  log_info "Claude Code already installed."
  exit 0
fi

install_script="$(mktemp)"
curl -fsSL https://claude.ai/install.sh -o "${install_script}"
bash "${install_script}"
rm -f "${install_script}"

log_info "claude_code completed successfully."
