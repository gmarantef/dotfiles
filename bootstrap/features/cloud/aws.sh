#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

install_aws_cli_linux() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cd "${tmp_dir}"

  local url
  if [ "${ARCHITECTURE}" = "x86_64" ]; then
    url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  elif echo "${ARCHITECTURE}" | grep -qi arm; then
    url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
  else
    log_error "Unsupported architecture: ${ARCHITECTURE}"
  fi

  curl -fsSL "${url}" -o awscliv2.zip
  unzip -q awscliv2.zip
  sudo ./aws/install

  cd - >/dev/null
  rm -rf "${tmp_dir}"
}

install_aws_cli_macos() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cd "${tmp_dir}"

  curl -fsSL https://awscli.amazonaws.com/AWSCLIV2.pkg -o AWSCLIV2.pkg
  sudo installer -pkg AWSCLIV2.pkg -target /

  cd - >/dev/null
  rm -rf "${tmp_dir}"
}

log_step "Configuring AWS CLI..."

if command -v aws >/dev/null 2>&1; then
  log_info "AWS CLI already installed."
  exit 0
fi

log_info "Installing AWS CLI v2..."

case "${OS}" in
  linux)   install_aws_cli_linux ;;
  darwin)  install_aws_cli_macos ;;
  *)       log_error "Unsupported OS for AWS CLI: ${OS}" ;;
esac

log_info "AWS cloud provider completed successfully."
