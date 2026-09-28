# Contributing

This started as a personal lab notebook, so there's no formal process, but
a few ground rules keep it useful and safe:

## What's welcome

- Corrections to anything in `digest/` — if a root cause, workaround, or
  status is wrong or stale, open an issue or PR.
- "I hit this too" confirmations, ideally with your own repro details
  (versions, config) — strengthens the case when reporting upstream.
- Links to related upstream discussion/issues/PRs this repo doesn't yet
  reference.

## What doesn't belong here

- Real credentials, tokens, internal hostnames, internal IPs, or private
  file paths — even in a code block, even redacted-but-guessable. If you're
  not sure, leave it out or ask first.
- Duplicate reports of the exact same bug without new information — check
  `tracker/issues.md` first.
- General support questions for Chaptarr/Grimmory that aren't specific
  bugs — those belong in the projects' own discussion boards.

## Before opening a PR

If you're adding a `notes/` or `digest/` entry, use the `_template.md` in
that folder as a starting point. Run `scripts/scan-leaks.sh` against your
changes before opening the PR — it's the same [gitleaks](https://github.com/gitleaks/gitleaks)-backed
check the commit hook and CI both run, and running it yourself avoids a
round trip. Requires `gitleaks` installed locally (see the script's error
message for a one-liner); `scripts/setup.sh` wires it into a pre-commit
hook automatically.

Even if you skip the local hook, every push and PR is scanned server-side
by the `scan-leaks` GitHub Action — nothing merges without passing it.

## Style

- First person, specific, no marketing language.
- Cite version numbers, not "recent" or "latest" — Chaptarr and Grimmory
  both ship fast, and vague version references go stale within weeks.
- Every claim about "this is fixed" should link to the merged PR/commit
  that fixed it, not just "I think this is resolved."
