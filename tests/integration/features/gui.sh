#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: gui ==="

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/gui.sh"

# --- Assert VSCode (todas las distros) ---
assert_command code

# --- Assert Chrome (ubuntu y fedora tienen repo oficial; arch no) ---
distro=$(. /etc/os-release && echo "${ID}")
case "${distro}" in
  ubuntu|debian|fedora)
    if command -v google-chrome >/dev/null 2>&1 || command -v google-chrome-stable >/dev/null 2>&1; then
      log_pass "'google-chrome' disponible"
    else
      log_fail "'google-chrome' no encontrado tras la instalación"
    fi
    ;;
  *)
    log_pass "Chrome: distro '${distro}' sin repo oficial — skip esperado"
    ;;
esac

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/gui.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
