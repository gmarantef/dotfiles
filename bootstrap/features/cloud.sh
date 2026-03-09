#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../lib.sh
. "${BOOTSTRAP_DIR}/lib.sh"

# CLOUD_PROVIDERS se hereda del entorno exportado por run_once_bootstrap.sh.tmpl
# (La línea de template que había aquí era un bug: este fichero no es .tmpl)

log_step "Configuring cloud environment..."

if [ -z "${CLOUD_PROVIDERS}" ]; then
  log_warn "No cloud providers defined, skipping."
  exit 0
fi

for provider in ${CLOUD_PROVIDERS}; do
  case "${provider}" in
    aws)
      log_info "Running AWS provider setup..."
      . "$(dirname "$0")/cloud/aws.sh"
      ;;
    *)
      log_warn "Unknown cloud provider '${provider}', skipping."
      ;;
  esac
done

log_info "Cloud feature completed successfully."
