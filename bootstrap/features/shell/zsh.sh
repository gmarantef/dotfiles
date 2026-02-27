#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

echo "Configuring zsh shell..."

install_zsh_linux() {
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      sudo apt install -y zsh
      ;;
    fedora)
      sudo dnf install -y zsh
      ;;
    arch)
      sudo pacman -S zsh
    *)
      echo "Unsupported Linux distro for zsh: $ID"
      exit 1
      ;;
  esac
}

install_zsh_macos() {
  # zsh already comes in macOS
  if ! command -v zsh >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      brew "zsh"
    else
      echo "Brew is needed for installing zsh in macOS"
      exit 1
    fi
  fi
}

install_community_plugins() {
  case "$OS" in
    Linux)
      # Clone zsh-autosuggestions community plugin to oh-my-zsh
      git clone https://github.com/zsh-users/zsh-autosuggestions \
      ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

      # Clone zsh-syntax-highlighting community plugin to oh-my-zsh
      git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
      ;;
    Darwin)
      brew "zsh-autosuggestions"
      brew "zsh-syntax-highlighting"
      ;;
    *)
      echo "No community plugins added: $OS"
      ;;
  esac
}

# Install zsh if not exists
if ! command -v zsh >/dev/null 2>&1; then
  echo "Installing zsh ..."
  case "$OS" in
    Linux) install_zsh_linux ;;
    Darwin) install_zsh_macos ;;
    *)
      echo "OS not supported for zsh: $OS"
      exit 1
      ;;
  esac
fi

ZSH_PATH="$(command -v zsh)"

# Install oh-my-zsh if not exists
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh ..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install community plugins
echo "Installing oh-my-zsh community plugins ..."
install_community_plugins

# Cambiar shell por defecto
if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "Setting zsh as default shell..."
  chsh -s "$ZSH_PATH"
fi

echo "zsh and oh-my-zsh successfully configured."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "zsh shell completed successfully."