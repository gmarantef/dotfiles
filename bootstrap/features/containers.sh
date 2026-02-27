#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

echo "Setting up container environment..."

install_lazydocker() {
  if command -v brew >/dev/null 2>&1; then
    if ! brew list lazydocker >/dev/null 2>&1; then
      echo "Installing lazydocker..."
      brew install lazydocker
    else
      echo "lazydocker already installed"
    fi
  else
    echo "Homebrew not found. Skipping lazydocker."
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
  echo "Applying Docker daemon configuration (Arch)..."

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

  sudo sysctl --system
  sudo systemctl restart docker
}

install_docker_arch() {

  sudo pacman -Syu

  sudo pacman -S docker

  sudo systemctl start docker
  sudo systemctl enable docker

  # Install docker compose because is packaged separately
  sudo pacman -S docker-compose
  sudo pacman -S docker-buildx

  # Configure docker
  configure_docker_arch

}

install_docker_linux() {
  if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed"
    return
  fi

  echo "Installing Docker Engine (Linux)..."

  . /etc/os-release
  case "$ID" in
    ubuntu|debian) install_docker_ubuntu_debian ;;
    fedora) install_docker_fedora ;;
    arch) install_docker_arch ;;
    *)
      echo "Unsupported Linux distro for docker: $ID"
      exit 1
      ;;
  esac

  # Add current user to docker group
  sudo usermod -aG docker "$USER"

  echo "Log out and back in for docker group permissions to apply."
}

install_docker_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew required on macOS."
    exit 1
  fi

  echo "Installing Colima and docker CLI..."

  # Install docker and colima
  brew install docker
  brew install colima

  # Install DDEV
  brew install drud/ddev/ddev
  brew upgrade ddev

  # Start colima if not running
  if ! colima status >/dev/null 2>&1; then
    echo "Starting Colima..."
    colima start --cpu 4 --memory 6 --disk 100 --dns=1.1.1.1
  fi

  # Config DDEV
  ddev config global --mutagen-enabled
  brew install nss
  mkcert -install
}

case "$OS" in
  Linux)
    install_docker_linux
    ;;
  Darwin)
    install_docker_macos
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

install_lazydocker

echo "Containers feature ready."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "containers feature completed successfully."