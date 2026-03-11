#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: security ==="

# --- Setup ---
# security requiere brew; instalarlo si no está presente
ensure_brew

# Excluir gui de FEATURES para evitar intentar instalar Bitwarden GUI vía flatpak
# (flatpak no funciona de forma fiable dentro de contenedores Docker)
export FEATURES="security"

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/security.sh"

# --- Assert ---
assert_command bw
assert_command jq

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/security.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
