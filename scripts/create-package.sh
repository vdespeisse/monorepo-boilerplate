#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <package-name> [--scoped]

Creates a new empty package under packages/<package-name> using templates in scripts/boilerplate.

Arguments:
  <package-name>   Kebab-case name of the package directory (e.g., my-awesome-lib)

Options:
  --scoped         Prefix npm package name with '@' (e.g., "@my-awesome-lib")

Examples:
  $(basename "$0") utils
  $(basename "$0") data-tools --scoped
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] || (( $# < 1 )); then
  usage
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BOILERPLATE_DIR="${REPO_ROOT}/scripts/boilerplate"
cd "${REPO_ROOT}"

PKG_DIR_NAME="$1"
SCOPED="false"
if [[ "${2:-}" == "--scoped" ]]; then
  SCOPED="true"
fi

if [[ -z "${PKG_DIR_NAME}" ]]; then
  echo "Error: package name is required." >&2
  usage
  exit 1
fi

if [[ "${PKG_DIR_NAME}" == *"/"* ]]; then
  echo "Error: package name should not include path separators." >&2
  exit 1
fi

TARGET_DIR="${REPO_ROOT}/packages/${PKG_DIR_NAME}"
if [[ -e "${TARGET_DIR}" ]]; then
  echo "Error: ${TARGET_DIR} already exists." >&2
  exit 1
fi

echo "Creating package at ${TARGET_DIR} ..."
mkdir -p "${TARGET_DIR}/src"

# Derive npm package name
if [[ "${SCOPED}" == "true" ]]; then
  NPM_NAME="@${PKG_DIR_NAME}"
else
  NPM_NAME="${PKG_DIR_NAME}"
fi

# Copy templates
cp "${BOILERPLATE_DIR}/tsconfig.json.tpl" "${TARGET_DIR}/tsconfig.json"
cp "${BOILERPLATE_DIR}/package.json.tpl" "${TARGET_DIR}/package.json"
cp "${BOILERPLATE_DIR}/src/index.ts.tpl" "${TARGET_DIR}/src/index.ts"

# Replace placeholders (BSD-compatible sed for macOS)
ESCAPED_NPM_NAME=$(printf '%s\n' "${NPM_NAME}" | sed -e 's/[\\/&]/\\&/g')
sed -i '' -e "s/__NPM_NAME__/${ESCAPED_NPM_NAME}/g" "${TARGET_DIR}/package.json"

echo "Package ${NPM_NAME} created."
echo "Next steps:"
echo "  - npm run build"
echo "  - Add tests in packages/${PKG_DIR_NAME}/ and run 'npm run test'"


