#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: brew ==="

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/brew.sh"

# Brew en Linux instala en /home/linuxbrew — añadir al PATH para el assert
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- Assert ---
assert_command brew

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/brew.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
