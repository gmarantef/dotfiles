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
      ;;
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
    linux)
      local plugins_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins"
      if [ ! -d "${plugins_dir}/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
          "${plugins_dir}/zsh-autosuggestions"
      fi
      if [ ! -d "${plugins_dir}/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting \
          "${plugins_dir}/zsh-syntax-highlighting"
      fi
      ;;
    darwin)
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
    linux)   install_zsh_linux ;;
    darwin)  install_zsh_macos ;;
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
