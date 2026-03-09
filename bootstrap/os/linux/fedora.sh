#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_step "Preparing Fedora system..."

sudo dnf install -y \
  curl \
  git \
  ca-certificates \
  @development-tools \
  file \
  gnupg2 \
  glibc \
  groff \
  less

log_info "Fedora base packages installed."
