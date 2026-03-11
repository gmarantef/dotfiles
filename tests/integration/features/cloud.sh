#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: cloud (aws) ==="

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/cloud.sh"

# --- Assert ---
assert_command aws
assert_command aws  # comprobar también con which para confirmar que está en PATH
aws --version

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/cloud.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
