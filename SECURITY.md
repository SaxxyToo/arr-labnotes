# Security

This repo is testing notes about self-hosted software, written from a real
homelab. Real effort goes into keeping internal details (hostnames, internal
IPs, file paths, API keys/tokens) out of it — every commit and PR is scanned
with [gitleaks](https://github.com/gitleaks/gitleaks) (stock ruleset plus
homelab-specific custom rules in `.gitleaks.toml`), both locally via a
pre-commit hook and server-side via GitHub Actions on every push/PR — but no
automated scan is perfect.

## If you find something that looks like a real credential or internal detail

Please **don't open a public issue**. Instead:

- Email: reports@saxlab.dev <!-- labnotes:allow-secret -->
- Or use GitHub's private vulnerability reporting if enabled on this repo

I'll redact/rotate as needed and credit the report unless you'd rather stay
anonymous.

## Scope note

This repo does not run any code that touches production systems — it's
notes, and small reproduction files (synthetic test media, config snippets).
Nothing here is a security advisory for Chaptarr or Grimmory themselves;
report those upstream in their own repos.
