#!/usr/bin/env sh
set -e

echo "Configuring shell..."

if [ -z "${DEFAULT_SHELL}" ]; then
  echo "No default shell defined."
  exit 0
fi

case "$DEFAULT_SHELL" in
  zsh)
    . "$(dirname "$0")/shell/zsh.sh"
    ;;
  *)
    echo "Unknown shell: $DEFAULT_SHELL"
    ;;
esac

echo "shell feature completed successfully."