#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: shell ==="

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/shell.sh"

# --- Assert ---
assert_command zsh
assert_dir "${HOME}/.oh-my-zsh"

# Verificar plugins comunitarios clonados en Linux
if [ "${OS}" = "linux" ]; then
  assert_dir "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  assert_dir "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/shell.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
