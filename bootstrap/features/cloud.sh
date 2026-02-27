#!/usr/bin/env sh
set -e

CLOUD_PROVIDERS="{{ join " " .data.cloud_providers }}"

echo "Configuring cloud environment..."

if [ -z "${CLOUD_PROVIDERS}" ]; then
  echo "No cloud providers defined."
  exit 0
fi

for provider in $CLOUD_PROVIDERS; do
  case "$provider" in
    aws)
      . "$(dirname "$0")/cloud/aws.sh"
      ;;
    *)
      echo "Unknown cloud provider: $provider"
      ;;
  esac
done

echo "Cloud feature completed successfully."