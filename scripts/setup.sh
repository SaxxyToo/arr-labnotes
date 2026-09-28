#!/usr/bin/env bash
# One-time setup for a freshly cloned copy of this repo.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chmod +x "$REPO_ROOT/.githooks/pre-commit" "$REPO_ROOT/scripts/scan-leaks.sh"
git -C "$REPO_ROOT" config core.hooksPath .githooks
echo "arr-labnotes: git hooksPath set to .githooks. Leak scan will run on every commit."
