#!/usr/bin/env bash
# tests/integration/helpers.sh — utilidades compartidas para los tests de integración
# Usar con: . /helpers.sh  (se monta en / dentro del contenedor)
# No ejecutar directamente.

[ -n "${_TEST_HELPERS_SOURCED:-}" ] && return 0
_TEST_HELPERS_SOURCED=1

PASS_COUNT=0
FAIL_COUNT=0

# ── Logging ───────────────────────────────────────────────────────────────────

log_pass() { echo "[PASS] $*"; PASS_COUNT=$((PASS_COUNT + 1)); }
log_fail() { echo "[FAIL] $*" >&2; FAIL_COUNT=$((FAIL_COUNT + 1)); }
log_info() { echo "[INFO] $*"; }

# ── Assertions ────────────────────────────────────────────────────────────────

assert_command() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    log_pass "'${cmd}' disponible en PATH"
  else
    log_fail "'${cmd}' no encontrado tras la instalación"
  fi
}

assert_file() {
  local path="$1"
  if [ -f "${path}" ]; then
    log_pass "Fichero '${path}' existe"
  else
    log_fail "Fichero '${path}' no encontrado"
  fi
}

assert_dir() {
  local path="$1"
  if [ -d "${path}" ]; then
    log_pass "Directorio '${path}' existe"
  else
    log_fail "Directorio '${path}' no encontrado"
  fi
}

# ── Mocks ─────────────────────────────────────────────────────────────────────

# Sustituye systemctl por un no-op: evita fallos por ausencia de systemd en Docker
mock_systemctl() {
  local mock_dir="${HOME}/.local/bin"
  mkdir -p "${mock_dir}"
  cat > "${mock_dir}/systemctl" <<'EOF'
#!/bin/bash
echo "[MOCK] systemctl $*"
exit 0
EOF
  chmod +x "${mock_dir}/systemctl"
  export PATH="${mock_dir}:${PATH}"
  log_info "systemctl mockeado"
}

# ── Prerequisitos ─────────────────────────────────────────────────────────────

# Asegura que brew está instalado y en PATH antes de correr features que lo necesiten
ensure_brew() {
  # Si ya está en PATH, nada que hacer
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  # Puede estar instalado pero no en PATH (caso Linux post-install)
  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    return 0
  fi
  log_info "Instalando brew como prerequisito..."
  bash "${BOOTSTRAP_DIR}/features/brew.sh"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

# ── Resumen final ─────────────────────────────────────────────────────────────

# Imprime el resumen y sale con código 1 si hubo algún fallo
test_summary() {
  echo ""
  echo "────────────────────────────────────────"
  echo "  ${PASS_COUNT} passed  |  ${FAIL_COUNT} failed"
  echo "────────────────────────────────────────"
  [ "${FAIL_COUNT}" -eq 0 ]
}
