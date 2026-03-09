#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_info "Detecting Linux distribution..."

if [ ! -f /etc/os-release ]; then
  log_error "Cannot detect Linux distribution: /etc/os-release not found"
fi

case "$(get_distro)" in
  ubuntu|debian)
    bash "${BOOTSTRAP_DIR}/os/linux/ubuntu.sh"
    ;;
  fedora)
    bash "${BOOTSTRAP_DIR}/os/linux/fedora.sh"
    ;;
  arch)
    bash "${BOOTSTRAP_DIR}/os/linux/arch.sh"
    ;;
  *)
    log_error "Unsupported Linux distribution: $(get_distro)"
    ;;
esac
