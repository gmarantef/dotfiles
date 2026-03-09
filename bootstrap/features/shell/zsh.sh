#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Configuring zsh shell..."

install_zsh_linux() {
  case "$(get_distro)" in
    ubuntu|debian)
      sudo apt install -y zsh
      ;;
    fedora)
      sudo dnf install -y zsh
      ;;
    arch)
      sudo pacman -S --noconfirm zsh
      ;;  # bug fix: ;; faltante en el caso arch
    *)
      log_error "Unsupported Linux distro for zsh: $(get_distro)"
      ;;
  esac
}

install_zsh_macos() {
  if ! command -v zsh >/dev/null 2>&1; then
    require_command brew "Run the 'brew' feature first."
    brew install zsh
  fi
}

install_community_plugins() {
  case "${OS}" in
    Linux)
      git clone https://github.com/zsh-users/zsh-autosuggestions \
        "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
      git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
      ;;
    Darwin)
      brew install zsh-autosuggestions
      brew install zsh-syntax-highlighting
      ;;
    *)
      log_warn "No community plugins added for OS: ${OS}"
      ;;
  esac
}

if ! command -v zsh >/dev/null 2>&1; then
  log_info "Installing zsh..."
  case "${OS}" in
    Linux)   install_zsh_linux ;;
    Darwin)  install_zsh_macos ;;
    *)       log_error "OS not supported for zsh: ${OS}" ;;
  esac
fi

ZSH_PATH="$(command -v zsh)"

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  log_info "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

log_info "Installing oh-my-zsh community plugins..."
install_community_plugins

if [ "${SHELL}" != "${ZSH_PATH}" ]; then
  log_info "Setting zsh as default shell..."
  chsh -s "${ZSH_PATH}"
fi

log_info "zsh and oh-my-zsh successfully configured."
log_info "zsh shell completed successfully."
