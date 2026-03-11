#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: gui (ubuntu/debian only) ==="

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/gui.sh"

# --- Assert ---
# El binario se instala en /usr/bin/google-chrome o /usr/bin/google-chrome-stable
if command -v google-chrome >/dev/null 2>&1 || command -v google-chrome-stable >/dev/null 2>&1; then
  log_pass "'google-chrome' disponible"
else
  log_fail "'google-chrome' no encontrado tras la instalación"
fi

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/gui.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
