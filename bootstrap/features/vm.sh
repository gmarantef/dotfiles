#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Configuring Virtual Machine tools..."

install_virtualization_tools_ubuntu() {
  sudo apt update

  log_info "Installing QEMU + libvirt..."
  sudo apt install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    libvirt-dev \
    virtinst \
    bridge-utils \
    pkg-config \
    ruby-dev \
    zlib1g-dev

  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd

  sudo usermod -aG libvirt "${USER}"

  log_info "Installing Vagrant..."
  if ! command -v vagrant >/dev/null 2>&1; then
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install -y vagrant
  else
    log_info "Vagrant already installed."
  fi

  log_info "Installing vagrant-libvirt plugin if missing..."
  if ! vagrant plugin list | grep -q vagrant-libvirt; then
    vagrant plugin install vagrant-libvirt
  else
    log_info "vagrant-libvirt already installed."
  fi
}

install_virtualization_tools_linux() {
  case "$(get_distro)" in
    ubuntu|debian)
      install_virtualization_tools_ubuntu
      ;;
    fedora)
      log_warn "Fedora virtualization support not implemented yet."
      ;;
    arch)
      log_warn "Arch virtualization support not implemented yet."
      ;;
    *)
      log_error "Linux distro not officially supported for virtualization: $(get_distro)"
      ;;
  esac
}

case "${OS}" in
  Linux)
    install_virtualization_tools_linux
    ;;
  Darwin)
    log_warn "macOS virtualization support not implemented yet."
    exit 0
    ;;
  *)
    log_error "Unsupported OS: ${OS}"
    ;;
esac

log_info "Virtualization environment successfully configured."
log_info "VM feature completed successfully."
