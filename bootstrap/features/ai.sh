#!/usr/bin/env sh
set -e

echo "Configuring AI agents..."

if [ -z "${AI_AGENTS}" ]; then
  echo "No AI agents defined."
  exit 0
fi

for agent in $AI_AGENTS; do
  case "$agent" in
    claude_code)
      echo "Running claude_code agent setup"
      . "$(dirname "$0")/ai/claude_code.sh"
      ;;
    *)
      echo "Unknown AI agent: $agent"
      ;;
  esac
done

echo "ai feature completed successfully."
