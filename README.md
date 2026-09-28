# arr-labnotes

A running lab notebook for bugs, quirks, and fixes found while using and
testing [Chaptarr](https://github.com/Chaptarr/chaptarr) (a Readarr fork
for audiobooks/ebooks) and [Grimmory](https://github.com/grimmory-tools/grimmory)
(a self-hosted book/audiobook metadata server), plus whatever else in the
*arr / self-hosted-media-management space we end up poking at.

**This is not an official project of either tool.** It's one user's
testing notes — the goal is to keep a public, organized record of what's
been found, what's confirmed, what's been reported upstream, and where
each report stands. If you hit the same bug, this might save you time;
if you're a maintainer, the [tracker](tracker/issues.md) links straight
to the filed issues/PRs with supporting detail.

## Layout

| Folder | What's in it |
|---|---|
| [`notes/`](notes/) | Raw, dated working notes — first draft thinking, as things are being investigated. Not polished. Read `digest/` first; come here for the messy trail. |
| [`digest/`](digest/) | Curated write-ups, one per bug/topic (`chaptarr/`, `grimmory/`, `other/` for adjacent tools). Stable structure: symptom, cause, fix/status, links. This is the "what we know" layer. Start with [`pipeline-architecture.md`](digest/pipeline-architecture.md) for the generic *arr → metadata-engine → media-server flow these bugs live in. |
| [`tracker/issues.md`](tracker/issues.md) | One table: everything filed upstream (issues + PRs), which project, current status, and a link to the digest entry with the full story. |

## Status legend

Used in `tracker/issues.md` and the header of each `digest/` entry.

| Status | Meaning |
|---|---|
| `investigating` | Actively being characterized; no upstream report yet |
| `filed` | Reported upstream (issue or discussion), no fix yet |
| `pr-open` | A fix PR exists upstream, not yet merged |
| `fixed-upstream` | Merged and confirmed in a release |
| `wontfix` / `by-design` | Maintainer response was "not a bug" or declined |

## Contributing

This is mostly a personal notebook, but corrections, confirmations
("I hit this too"), and pointers to related upstream discussion are
welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## Safety

Notes here get sanitized of internal/homelab-specific details (hostnames,
internal IPs, file paths, credentials) before they're committed — enforced
by [gitleaks](https://github.com/gitleaks/gitleaks) both as a local
pre-commit hook and as a required GitHub Actions check on every push/PR
(`.gitleaks.toml` has the ruleset). See [SECURITY.md](SECURITY.md) if you
spot something that looks like it shouldn't be public.

## License

[MIT](LICENSE) — reuse whatever's useful.
