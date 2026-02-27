#!/usr/bin/env sh
set -e

#!/usr/bin/env sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

install_aws_cli() {
  if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI already installed"
    return
  fi

  echo "Installing AWS CLI v2 ..."

  case "$OS" in
    Linux)
      install_aws_cli_linux
      ;;
    Darwin)
      install_aws_cli_macos
      ;;
    *)
      echo "Unsupported OS for AWS CLI"
      exit 1
      ;;
  esac
}

install_aws_cli_linux() {
  TMP_DIR="$(mktemp -d)"
  cd "$TMP_DIR"

  if [ "$ARCHITECTURE" = "x86_64" ]; then
    URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  elif echo "$ARCHITECTURE" | grep -qi arm; then
    URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
  else
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
  fi

  curl -fsSL "$URL" -o awscliv2.zip
  unzip -q awscliv2.zip

  sudo ./aws/install

  cd - >/dev/null
  rm -rf "$TMP_DIR"
}

install_aws_cli_macos() {
  TMP_DIR="$(mktemp -d)"
  cd "$TMP_DIR"

  URL="https://awscli.amazonaws.com/AWSCLIV2.pkg"

  curl -fsSL "$URL" -o AWSCLIV2.pkg

  # Instala para el sistema (requiere sudo)
  sudo installer -pkg AWSCLIV2.pkg -target /

  cd - >/dev/null
  rm -rf "$TMP_DIR"
}

echo "Configuring AWS CLI ..."

install_aws_cli

echo "AWS CLI successfully configured."

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "AWS cloud provider completed successfully."