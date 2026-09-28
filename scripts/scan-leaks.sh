#!/usr/bin/env bash
# scan-leaks.sh — scan this repo for secrets and homelab-internal
# identifiers before they hit a public remote.
#
# Backed by gitleaks (https://github.com/gitleaks/gitleaks) using the
# stock ruleset (AWS/GCP/Azure keys, GitHub/Slack/Stripe tokens, private
# key blocks, generic high-entropy secrets, ...) PLUS the homelab-specific
# custom rules in .gitleaks.toml (internal hostnames, private IP ranges,
# internal filesystem paths).
#
# Usage:
#   scripts/scan-leaks.sh            # scan working tree + git history (pre-push / manual audit)
#   scripts/scan-leaks.sh --staged   # scan only staged changes (fast path for the commit hook)
#
# Exit code 0 = clean, 1 = findings (or gitleaks missing — fails closed).

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG="${REPO_ROOT}/.gitleaks.toml"

if ! command -v gitleaks >/dev/null 2>&1; then
  cat >&2 <<'EOF'
scan-leaks: gitleaks is not installed — refusing to commit/push without it
(failing closed rather than falling back to a weaker check).

Install it:
  # Linux/macOS, one-liner (check https://github.com/gitleaks/gitleaks/releases for the latest):
  curl -sL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_$(uname -s)_$(uname -m).tar.gz \
    | tar xz gitleaks && sudo mv gitleaks /usr/local/bin/

  # Homebrew:
  brew install gitleaks
EOF
  exit 1
fi

mode="${1:-full}"

case "$mode" in
  --staged)
    gitleaks protect --source "$REPO_ROOT" --config "$CONFIG" --staged --redact -v
    ;;
  full|"")
    gitleaks detect --source "$REPO_ROOT" --config "$CONFIG" --redact -v
    ;;
  *)
    echo "usage: $0 [--staged]" >&2
    exit 2
    ;;
esac
