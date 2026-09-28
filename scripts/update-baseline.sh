#!/usr/bin/env bash
# update-baseline.sh — regenerate .gitleaks-baseline.json after confirming
# by eye that every current gitleaks finding is a real false positive.
#
# Use this ONLY when scan-leaks.sh blocks something you've manually
# verified is not a real secret (e.g. a documentation example, a synthetic
# test fixture). It does NOT hide anything silently — the baseline file is
# committed to the repo, so every suppressed finding is visible in the PR
# diff and reviewable by anyone.
#
# Do NOT run this reflexively to make a red scan go green. Read every
# finding gitleaks reports first; only re-baseline if you're certain.
set -euo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel)"
CONFIG="${REPO_ROOT}/.gitleaks.toml"
BASELINE="${REPO_ROOT}/.gitleaks-baseline.json"

echo "Current findings (about to become the new baseline if you continue):"
gitleaks detect --source "$REPO_ROOT" --config "$CONFIG" --redact -v || true

read -r -p "Accept ALL current findings above as known-safe false positives? [y/N] " ans
if [[ "$ans" != "y" && "$ans" != "Y" ]]; then
  echo "Aborted — baseline not changed."
  exit 1
fi

gitleaks detect --source "$REPO_ROOT" --config "$CONFIG" \
  --report-format json --report-path "$BASELINE" --exit-code 0
echo "Wrote $BASELINE — review the diff and commit it."
