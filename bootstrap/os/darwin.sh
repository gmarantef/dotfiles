#!/usr/bin/env sh
set -e

echo "🔧 Preparing macOS base system..."

# Detect macOS version
MACOS_VERSION="$(sw_vers -productVersion)"
export MACOS_VERSION
echo "macOS version: $MACOS_VERSION"

# Ensure Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "⚠️  Please complete installation and re-run bootstrap."
  exit 1
fi

# Ensure basic tools
for cmd in curl git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required tool: $cmd"
    echo "Install Xcode CLI tools properly."
    exit 1
  fi
done

echo "✅ macOS base ready"