#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Setting up container environment..."

install_lazydocker() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list lazydocker >/dev/null 2>&1; then
      log_info "Installing lazydocker..."
      brew install lazydocker
    else
      log_info "lazydocker already installed."
    fi
  else
    log_warn "Homebrew not found. Skipping lazydocker."
  fi
}

install_docker_ubuntu_debian() {
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update

  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

install_docker_fedora() {
  sudo dnf remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine || true

  sudo dnf -y install dnf-plugins-core

  sudo dnf config-manager addrepo --from-repofile \
   https://download.docker.com/linux/fedora/docker-ce.repo

  sudo dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

configure_docker_arch() {
  log_info "Applying Docker daemon configuration (Arch)..."

  sudo mkdir -p /etc/docker

  sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "storage-driver": "overlay2",
  "dns": ["1.1.1.1", "8.8.8.8"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "iptables": true
}
EOF

  sudo tee /etc/sysctl.d/99-docker-ipforward.conf > /dev/null <<EOF
net.ipv4.ip_forward = 1
EOF

  sudo sysctl --system || log_warn "sysctl --system failed. Network forwarding may need manual config."
  sudo systemctl restart docker
}

install_docker_arch() {
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm docker
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo pacman -S --noconfirm docker-compose docker-buildx
  configure_docker_arch
}

install_docker_linux() {
  if command -v docker >/dev/null 2>&1; then
    log_info "Docker already installed."
    return
  fi

  log_info "Installing Docker Engine (Linux)..."

  case "$(get_distro)" in
    ubuntu|debian) install_docker_ubuntu_debian ;;
    fedora)        install_docker_fedora ;;
    arch)          install_docker_arch ;;
    *)
      log_error "Unsupported Linux distro for docker: $(get_distro)"
      ;;
  esac

  sudo usermod -aG docker "${USER}"
  log_warn "Log out and back in for docker group permissions to apply."
}

install_docker_macos() {
  require_command brew "Run the 'brew' feature first."

  log_info "Installing Colima and docker CLI..."

  brew install docker
  brew install colima

  brew install drud/ddev/ddev
  brew upgrade ddev

  if ! colima status >/dev/null 2>&1; then
    log_info "Starting Colima..."
    colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1
  fi

  ddev config global --mutagen-enabled
  brew install nss
  mkcert -install
}

case "${OS}" in
  Linux)
    install_docker_linux
    ;;
  Darwin)
    install_docker_macos
    ;;
  *)
    log_error "Unsupported OS: ${OS}"
    ;;
esac

install_lazydocker

log_info "Containers feature completed successfully."
