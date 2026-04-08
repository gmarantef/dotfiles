#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

log_step "Preparing Ubuntu/Debian system..."

sudo apt update
sudo apt install -y \
  curl \
  git \
  ca-certificates \
  build-essential \
  file \
  gnupg \
  groff \
  less

log_info "Ubuntu/Debian base packages installed."
