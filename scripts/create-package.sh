#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <package-name> [--scoped]

Creates a new empty package under packages/<package-name> modeled after demo-package.

Arguments:
  <package-name>   Kebab-case name of the package directory (e.g., my-awesome-lib)

Options:
  --scoped         Prefix npm package name with '@' (e.g., "@my-awesome-lib")

Examples:
  $(basename "$0") utils
  $(basename "$0") data-tools --scoped
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${#}" -lt 1 ]]; then
  usage
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
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

# package.json
cat > "${TARGET_DIR}/package.json" <<JSON
{
  "name": "${NPM_NAME}",
  "version": "0.0.1",
  "types": "./dist/index.d.ts",
  "main": "./dist/index.js",
  "type": "module",
  "require": "./dist/index.cjs",
  "exports": {
    ".": {
      "require": "./dist/index.cjs",
      "import": "./dist/index.js"
    }
  },
  "files": [
    "dist"
  ],
  "scripts": {
    "build": "tsup-node src/index.ts --format esm,cjs --dts",
    "dev": "tsx src/index.ts",
    "test": "vitest run"
  },
  "author": "",
  "license": "ISC",
  "description": "",
  "dependencies": {}
}
JSON

# tsconfig.json
cat > "${TARGET_DIR}/tsconfig.json" <<JSON
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "./src",
    "outDir": "./dist"
  },
  "include": ["src"],
  "references": []
}
JSON

# src/index.ts
cat > "${TARGET_DIR}/src/index.ts" <<'TS'
export function hello(): string {
  return "hello";
}
TS

echo "Package ${NPM_NAME} created."
echo "Next steps:"
echo "  - npm run build"
echo "  - Add tests in packages/${PKG_DIR_NAME}/ and run 'npm run test'"


