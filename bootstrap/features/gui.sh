#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

sudo_keepalive

log_step "Configuring GUI packages..."

install_chrome_ubuntu() {
  local arch
  arch=$(dpkg --print-architecture 2>/dev/null || echo "unknown")
  if [ "${arch}" != "amd64" ]; then
    log_warn "Google Chrome only provides official Linux packages for amd64. Skipping (arch: ${arch})."
    return
  fi

  curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg

  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] \
https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

  sudo apt update
  sudo apt install -y google-chrome-stable
}

install_chrome_fedora() {
  if [ "${ARCHITECTURE}" != "x86_64" ]; then
    log_warn "Google Chrome only provides official Linux packages for x86_64. Skipping (arch: ${ARCHITECTURE})."
    return
  fi

  sudo tee /etc/yum.repos.d/google-chrome.repo > /dev/null <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

  sudo dnf install -y google-chrome-stable
}

install_vscode_linux() {
  local distro
  distro="$(get_distro)"
  case "${distro}" in
    ubuntu|debian)
      curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
      echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
      sudo apt update
      sudo apt install -y code
      ;;
    fedora)
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
      sudo dnf install -y code
      ;;
    arch)
      sudo pacman -S --noconfirm code
      ;;
    *)
      log_warn "VSCode installation not supported for distro: ${distro}"
      ;;
  esac
}

if ! command -v code >/dev/null 2>&1; then
  log_info "Installing VSCode..."
  case "${OS}" in
    linux)
      install_vscode_linux
      ;;
    darwin)
      require_command brew "Run the 'brew' feature first."
      brew install --cask visual-studio-code
      ;;
    *)
      log_warn "OS not supported for VSCode: ${OS}"
      ;;
  esac
  log_info "VSCode successfully installed."
else
  log_info "VSCode already installed."
fi

if command -v code >/dev/null 2>&1 && [ -n "${DOTFILES_VSCODE_EXTENSIONS:-}" ]; then
  log_info "Installing VSCode extensions..."
  installed_exts="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
  for ext in ${DOTFILES_VSCODE_EXTENSIONS}; do
    if echo "${installed_exts}" | grep -qx "$(echo "${ext}" | tr '[:upper:]' '[:lower:]')"; then
      log_info "  Already installed: ${ext}"
    else
      log_info "  Installing: ${ext}"
      code --install-extension "${ext}" --force \
        || log_warn "  Failed to install extension ${ext} (skipping)"
    fi
  done
  log_info "VSCode extensions configured."
fi

if ! command -v google-chrome >/dev/null 2>&1 && ! command -v google-chrome-stable >/dev/null 2>&1; then
  log_info "Installing Google Chrome..."
  case "${OS}" in
    linux)
      case "$(get_distro)" in
        ubuntu|debian) install_chrome_ubuntu ;;
        fedora)        install_chrome_fedora ;;
        *)             log_warn "Google Chrome installation not supported for distro: $(get_distro)" ;;
      esac
      ;;
    darwin)
      require_command brew "Run the 'brew' feature first."
      brew install --cask google-chrome
      ;;
    *)
      log_warn "OS not supported for Google Chrome: ${OS}"
      ;;
  esac
  log_info "Google Chrome successfully configured."
else
  log_info "Google Chrome already installed."
fi

if [ "${OS}" = "linux" ] && [ "${CONTEXT}" = "personal" ]; then
  case "$(get_distro)" in
    ubuntu|debian)
      log_info "Installing steam-devices udev rules..."
      sudo apt install -y steam-devices
      ;;
  esac
fi

log_info "GUI feature completed successfully."
