#!/usr/bin/env bash
set -euo pipefail

ITEM="${1:-}"

if [ -z "$ITEM" ]; then
  echo "Usage: aws-bw-helper <bitwarden-item-name>" >&2
  exit 1
fi

if [ -z "${BW_SESSION:-}" ]; then
  echo "Bitwarden session not unlocked. Run 'bw unlock' first." >&2
  exit 1
fi

# Sync vault to prevent been updated from other client
bw sync >/dev/null

# Get item from bitwarden
DATA=$(bw get item "$ITEM")

# Get fields from item named access_key and secret_key
ACCESS_KEY=$(echo "$DATA" | jq -r '.fields[] | select(.name=="access_key") | .value')
SECRET_KEY=$(echo "$DATA" | jq -r '.fields[] | select(.name=="secret_key") | .value')

if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
  echo "Missing access_key or secret_key in Bitwarden item: $ITEM" >&2
  exit 1
fi

# Output compatible con AWS credential_process
cat <<EOF
{
  "Version": 1,
  "AccessKeyId": "$ACCESS_KEY",
  "SecretAccessKey": "$SECRET_KEY",
  "SessionToken": null,
  "Expiration": null
}
EOF