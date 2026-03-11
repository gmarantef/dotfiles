#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../helpers.sh
. /helpers.sh

log_info "=== TEST: bundle ==="

# --- Setup ---
# bundle requiere brew
ensure_brew

# Crear un Brewfile mínimo de prueba (no usa el real gestionado por chezmoi)
cat > "${HOME}/.Brewfile" <<'EOF'
brew "tree"
EOF
log_info "Brewfile de prueba creado con: brew \"tree\""

# --- Run ---
bash "${BOOTSTRAP_DIR}/features/bundle.sh"

# tree queda en el prefix de brew — asegurar PATH
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- Assert ---
assert_command tree

# --- Idempotencia ---
log_info "Testing idempotency..."
bash "${BOOTSTRAP_DIR}/features/bundle.sh"
log_pass "idempotencia: segunda ejecución sin errores"

test_summary
