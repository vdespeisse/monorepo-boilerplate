#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <package-name> [options]

Creates a new empty package using templates in scripts/boilerplate.

Arguments:
  <package-name>   Kebab-case name of the package directory (e.g., my-awesome-lib)

Options:
  --scoped         Prefix npm package name with workspace scope (e.g., "@4loop-workflows/my-lib")
  --dir <dir>      Target directory (default: packages). Must be a valid workspace directory.

Examples:
  $(basename "$0") utils                     # Creates packages/utils with name "utils"
  $(basename "$0") utils --scoped            # Creates packages/utils with name "@4loop-workflows/utils"
  $(basename "$0") my-app --dir apps         # Creates apps/my-app with name "my-app"
  $(basename "$0") my-app --dir apps --scoped # Creates apps/my-app with name "@4loop-workflows/my-app"
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

# Parse arguments
PKG_DIR_NAME=""
SCOPED="false"
TARGET_BASE="packages"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scoped)
      SCOPED="true"
      shift
      ;;
    --dir)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --dir requires a directory argument." >&2
        exit 1
      fi
      TARGET_BASE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -z "${PKG_DIR_NAME}" ]]; then
        PKG_DIR_NAME="$1"
      else
        echo "Error: Unexpected argument: $1" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "${PKG_DIR_NAME}" ]]; then
  echo "Error: package name is required." >&2
  usage
  exit 1
fi

if [[ "${PKG_DIR_NAME}" == *"/"* ]]; then
  echo "Error: package name should not include path separators." >&2
  exit 1
fi

# Validate target directory is a valid workspace
# Extract workspace base directories from package.json workspaces field
# Workspace patterns like "packages/*" or "packages/adapters/*" become "packages" or "packages/adapters"
VALID_WORKSPACE_DIRS=$(node -e "
  const pkg = require('${REPO_ROOT}/package.json');
  const workspaces = pkg.workspaces || [];
  const dirs = workspaces
    .map(w => w.replace(/\/\*$/, ''))
    .filter(d => d && !d.includes('*'));
  console.log(dirs.join('|'));
")

if [[ -z "${VALID_WORKSPACE_DIRS}" ]]; then
  echo "Error: Could not read workspaces from package.json." >&2
  exit 1
fi

# Check if TARGET_BASE matches any valid workspace directory
VALID=false
IFS='|' read -ra DIRS <<< "${VALID_WORKSPACE_DIRS}"
for dir in "${DIRS[@]}"; do
  if [[ "${TARGET_BASE}" == "${dir}" ]]; then
    VALID=true
    break
  fi
done

if [[ "${VALID}" != "true" ]]; then
  echo "Error: --dir must be one of the valid workspace directories: ${VALID_WORKSPACE_DIRS//|/, }" >&2
  exit 1
fi

TARGET_DIR="${REPO_ROOT}/${TARGET_BASE}/${PKG_DIR_NAME}"
if [[ -e "${TARGET_DIR}" ]]; then
  echo "Error: ${TARGET_DIR} already exists." >&2
  exit 1
fi

echo "Creating package at ${TARGET_DIR} ..."
mkdir -p "${TARGET_DIR}/src"

# Derive npm package name
if [[ "${SCOPED}" == "true" ]]; then
  # Extract scope from root package.json (e.g., "@4loop-workflows" from "name": "@4loop-workflows")
  ROOT_SCOPE=$(grep '"name"' "${REPO_ROOT}/package.json" | sed -E 's/.*"name":[[:space:]]*"(@[^/"]+)".*/\1/')
  if [[ -z "${ROOT_SCOPE}" || "${ROOT_SCOPE}" != @* ]]; then
    echo "Error: Could not extract scope from root package.json. Expected a scoped name like @org-name." >&2
    exit 1
  fi
  NPM_NAME="${ROOT_SCOPE}/${PKG_DIR_NAME}"
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
echo "  - Add tests in ${TARGET_BASE}/${PKG_DIR_NAME}/ and run 'npm run test'"


