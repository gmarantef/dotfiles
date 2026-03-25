#!/usr/bin/env bash
# bootstrap/lib.sh — utilidades compartidas para todos los scripts de bootstrap
# Usar con: . "${BOOTSTRAP_DIR}/lib.sh"
# No ejecutar directamente.

# Guard: evita doble source
[ -n "${_BOOTSTRAP_LIB_SOURCED:-}" ] && return 0
_BOOTSTRAP_LIB_SOURCED=1

set -euo pipefail

# ── Logging ───────────────────────────────────────────────────────────────────

log_info()  { echo "[INFO]  $*"; }
log_warn()  { echo "[WARN]  $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; exit 1; }
log_step()  { echo ""; echo "==> $*"; }

# ── Sudo keepalive ────────────────────────────────────────────────────────────
# Uso: sudo_keepalive  (registra auto-cleanup con trap EXIT)

sudo_keepalive() {
  log_info "Requesting sudo permissions..."
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  SUDO_PID=$!
  export SUDO_PID
  trap 'sudo_release' EXIT INT TERM
}

sudo_release() {
  if [ -n "${SUDO_PID:-}" ]; then
    kill "${SUDO_PID}" 2>/dev/null || true
    unset SUDO_PID
  fi
}

# ── Detección de distro ───────────────────────────────────────────────────────
# Devuelve el ID de la distro (ubuntu, debian, fedora, arch, ...)

get_distro() {
  if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

# ── Comprobaciones de dependencias ────────────────────────────────────────────

# Comprueba que un comando existe; aborta con mensaje claro si no
require_command() {
  local cmd="$1"
  local hint="${2:-}"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    if [ -n "${hint}" ]; then
      log_error "Required command '${cmd}' not found. ${hint}"
    else
      log_error "Required command '${cmd}' not found."
    fi
  fi
}

# Devuelve las features de las que depende una feature dada (space-separated)
# Algunas dependencias son condicionales al OS (ej. brew solo es req en macOS para shell/containers/gui)
_feature_deps() {
  case "$1" in
    bundle)
      echo "brew"
      ;;
    security)
      echo "brew"
      ;;
    shell|containers|gui)
      [ "${OS:-}" = "darwin" ] && echo "brew" || echo ""
      ;;
    *)
      echo ""
      ;;
  esac
}

# ── Helpers de features ───────────────────────────────────────────────────────

has_feature() {
  echo " ${FEATURES} " | grep -qw "$1"
}

has_cloud_provider() {
  echo " ${CLOUD_PROVIDERS} " | grep -qw "$1"
}

has_ai_agent() {
  echo " ${AI_AGENTS} " | grep -qw "$1"
}
