#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

echo "Configuring Virtual Machine tools ..."

install_virtualization_tools_ubuntu() {
  sudo apt update

  # Install QEMU for KVM and libvirt as virtualization engine
  echo "Installing QEMU + libvirt ..."
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

  # Enabling and starting libvirtd
  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd

  # Adding current user to libvirt group
  sudo usermod -aG libvirt "$USER"

  # Install vagrant as virtualization orchestrator
  echo "Installing Vagrant..."
  if ! command -v vagrant >/dev/null 2>&1; then
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vagrant
  else
    echo "Vagrant already installed."
  fi

  echo "Installing vagrant-libvirt plugin if missing..."
  if ! vagrant plugin list | grep -q vagrant-libvirt; then
    vagrant plugin install vagrant-libvirt
  else
    echo "vagrant-libvirt already installed."
  fi
}

install_virtualization_tools_linux() {
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      install_virtualization_tools_ubuntu
      ;;
    fedora)
      echo "fedora support not implemented yet."
      ;;
    arch)
      echo "arch support not implemented yet."
      ;;
    *)
      echo "Linux distro not officially supported for virtualization: $ID"
      exit 1
      ;;
  esac
}

case "$OS" in
  linux)
    install_virtualization_tools_linux
    ;;
  macos)
    echo "macOS support not implemented yet."
    exit 1
    ;;
  *)
    log "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "Vitualization environment successfully configured."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "VM feature completed successfully."
