#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_step "Configuring AI agents..."

if [ -z "${AI_AGENTS}" ]; then
  log_warn "No AI agents defined, skipping."
  exit 0
fi

for agent in ${AI_AGENTS}; do
  case "${agent}" in
    claude_code)
      log_info "Running claude_code agent setup..."
      . "$(dirname "$0")/ai/claude_code.sh"
      ;;
    *)
      log_warn "Unknown AI agent '${agent}', skipping."
      ;;
  esac
done

log_info "AI feature completed successfully."
