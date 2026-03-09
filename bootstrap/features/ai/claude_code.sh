#!/usr/bin/env sh
set -e

echo "Installing Claude Code..."

if command -v claude >/dev/null 2>&1; then
  echo "Claude Code already installed."
  exit 0
fi

curl -fsSL https://claude.ai/install.sh | bash

echo "claude_code completed successfully."
