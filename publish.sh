#!/usr/bin/env bash
# Publish WraithWall toolkit packages to PyPI or TestPyPI.
#
# Prerequisites (one-time, you):
#   1. Push this repo to github.com/niffyhunt/wraithwall-toolkit
#   2. Create accounts: pypi.org + test.pypi.org (enable 2FA on both)
#   3. First upload per package: API token (Account → API tokens)
#      Username: __token__   Password: pypi-Ag...
#   4. After first upload: add PyPI "Trusted publisher" per project
#      (Owner: niffyhunt, Repo: wraithwall-toolkit, Workflow: publish.yml)
#      Then GitHub Actions can publish on tag without storing a token.
#
# Usage:
#   ./publish.sh testpypi    # safe dry-run index (recommended first)
#   ./publish.sh pypi        # production pypi.org
#
# Env (optional for non-interactive twine):
#   export TWINE_USERNAME=__token__
#   export TWINE_PASSWORD=pypi-Ag...
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-testpypi}"
PACKAGES=(canary-kit honeypot-mitre dml-spec)

if [[ "$TARGET" != "testpypi" && "$TARGET" != "pypi" ]]; then
  echo "Usage: $0 [testpypi|pypi]" >&2
  exit 1
fi

python3 -m pip install -q --upgrade pip build twine

echo "Publishing ${PACKAGES[*]} → ${TARGET}"
for pkg in "${PACKAGES[@]}"; do
  echo ""
  echo "── $pkg ──"
  cd "$ROOT/$pkg"
  rm -rf dist build *.egg-info
  python3 -m build
  if [[ "$TARGET" == "testpypi" ]]; then
    twine upload --repository testpypi dist/*
  else
    twine upload dist/*
  fi
  echo "✓ $pkg uploaded"
done

echo ""
echo "Done. Verify install:"
if [[ "$TARGET" == "testpypi" ]]; then
  echo "  pip install -i https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ canary-kit"
else
  echo "  pip install canary-kit honeypot-mitre dml-spec"
fi