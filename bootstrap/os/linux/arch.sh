#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_step "Preparing Arch system..."

sudo pacman -Sy --noconfirm \
  curl \
  git \
  base-devel \
  file \
  gnupg \
  glibc \
  groff \
  less

log_info "Arch base packages installed."
