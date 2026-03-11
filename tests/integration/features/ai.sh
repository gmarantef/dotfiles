#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: ai (claude_code) ==="

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/ai.sh"

# Claude Code instala el binario en ~/.local/bin
export PATH="${HOME}/.local/bin:${PATH}"

# --- Assert ---
assert_command claude

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/ai.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
