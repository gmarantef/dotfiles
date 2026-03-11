#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: containers ==="

# --- Setup ---
# systemctl no está disponible en Docker — mockear para que el script no aborte
mock_systemctl

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/containers.sh"

# --- Assert ---
assert_command docker

# lazydocker se salta si brew no está presente (log_warn en el script) — no es un fallo

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/containers.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
