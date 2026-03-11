#!/usr/bin/env bash
# tests/integration/run_tests.sh
# Uso:
#   ./run_tests.sh                     → todas las distros, todas las features
#   ./run_tests.sh ubuntu              → ubuntu, todas las features
#   ./run_tests.sh ubuntu brew         → ubuntu, sólo brew
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${TESTS_DIR}/../.." && pwd)"

DISTRO_FILTER="${1:-all}"
FEATURE_FILTER="${2:-all}"

ALL_DISTROS="ubuntu fedora arch"
ALL_FEATURES="brew bundle shell cloud ai security containers gui"

# ── Matriz de exclusiones ─────────────────────────────────────────────────────
# gui sólo implementada para ubuntu/debian en el bootstrap
should_skip() {
  local distro="$1"
  local feature="$2"
  case "${distro}:${feature}" in
    fedora:gui) return 0 ;;
    arch:gui)   return 0 ;;
    *)          return 1 ;;
  esac
}

# ── Helpers de output ─────────────────────────────────────────────────────────

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

result_pass() { echo "  [PASS] ${1}::${2}"; PASS_COUNT=$((PASS_COUNT + 1)); }
result_fail() { echo "  [FAIL] ${1}::${2}"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
result_skip() { echo "  [SKIP] ${1}::${2}"; SKIP_COUNT=$((SKIP_COUNT + 1)); }

# ── Build de imágenes ─────────────────────────────────────────────────────────

build_image() {
  local distro="$1"
  echo ""
  echo "==> Building bootstrap-test-${distro}..."
  docker build \
    --quiet \
    -f "${TESTS_DIR}/dockerfiles/Dockerfile.${distro}" \
    -t "bootstrap-test-${distro}" \
    "${REPO_ROOT}" \
    || { echo "[ERROR] Build failed for ${distro}"; exit 1; }
}

# ── Ejecución de un test ──────────────────────────────────────────────────────

run_test() {
  local distro="$1"
  local feature="$2"
  local test_script="${TESTS_DIR}/features/${feature}.sh"

  if [ ! -f "${test_script}" ]; then
    result_skip "${distro}" "${feature} (sin script de test)"
    return
  fi

  if should_skip "${distro}" "${feature}"; then
    result_skip "${distro}" "${feature}"
    return
  fi

  if docker run \
      --rm \
      --privileged \
      -v "${test_script}:/test.sh:ro" \
      -v "${TESTS_DIR}/helpers.sh:/helpers.sh:ro" \
      "bootstrap-test-${distro}" \
      bash /test.sh; then
    result_pass "${distro}" "${feature}"
  else
    result_fail "${distro}" "${feature}"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

# Determinar qué distros y features correr
if [ "${DISTRO_FILTER}" = "all" ]; then
  distros="${ALL_DISTROS}"
else
  distros="${DISTRO_FILTER}"
fi

if [ "${FEATURE_FILTER}" = "all" ]; then
  features="${ALL_FEATURES}"
else
  features="${FEATURE_FILTER}"
fi

# Build de imágenes necesarias
for distro in ${distros}; do
  build_image "${distro}"
done

# Ejecución de tests
echo ""
echo "==> Running tests..."
echo ""
for distro in ${distros}; do
  echo "── ${distro} ──────────────────────────────"
  for feature in ${features}; do
    run_test "${distro}" "${feature}"
  done
done

# Resumen
echo ""
echo "════════════════════════════════════════"
echo "  ${PASS_COUNT} passed | ${FAIL_COUNT} failed | ${SKIP_COUNT} skipped"
echo "════════════════════════════════════════"

[ "${FAIL_COUNT}" -eq 0 ]
