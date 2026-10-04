# ManualImport explicitly-specified bookId/editionId silently remapped onto import-created duplicate book rows

- **Project:** Chaptarr
- **Status:** filed
- **Affects:** Chaptarr 0.9.965.0 (Docker on Unraid, PostgreSQL backend; reproduced 2026-10-03/04)
- **Filed:** [Chaptarr #285](https://github.com/Chaptarr/chaptarr/issues/285) (filed 2026-10-04)
- **Related notes:** —

## Symptom

A `ManualImport` command that specifies `authorId`, `bookId`, and
`editionId` explicitly completes and reports success — but the `BookFile`
lands on an edition of a **different book row for the same title** (the
newest duplicate), and the explicitly requested edition stays fileless.
No warning is logged; the explicit identifiers in the payload are
silently ignored.

The library had multiple book rows for the same title under one author
(three `Dark Age` rows under Pierce Brown; a duplicate `Golden Son`
row). The report initially attributed the duplicates to author-refresh
activity; the maintainer corrected that premise (see Cause). Two
imports in one session both landed on the wrong row
(`bookId=10317/editionId=25858` → edition 32214 of book 12938;
`bookId=9865/editionId=23583` → edition 32215 of book 12939).

## Cause

Maintainer-confirmed (bhoffman20, checked against `develop` e67374f):
the duplicate rows are **created by the import itself**, not by a
refresh. `ImportApprovedBooks` L384–427 runs a pinned-edition protection
branch: when the book has a pinned edition (`AnyEditionOk=false`) or a
`ManualAdd` edition that differs from the one the file matches, it
copies the book and the selected edition into a **new row and imports
there**, to keep automatic matching from overriding the pin.

Debug log confirms the clone branch fired for all three imports
(2026-10-03 23:43–23:53 UTC):

```
[MANUAL-EDITION-PROTECTION] User pinned edition 25115 ... Creating clone to preserve user's selection.
[MANUAL-EDITION-PROTECTION] Created new book instance ID: 12937 ...
[MANUAL-EDITION-PROTECTION] Created new book instance ID: 12938 ...
[MANUAL-EDITION-PROTECTION] Created new book instance ID: 12939 ...
```

12938/12939 (and their editions 32214/32215) being consecutive matches
the clone mechanism. This is a sibling of #111 but on a different
surface: #111 is the tracked-download path *rejecting* an import via
title-text matching; here the ManualImport path *overrides* explicit
IDs. Notably, #111's own recommended workaround — re-import with
explicit `bookId`/`editionId` — is exactly what loses to the protection
branch.

Open questions raised in the reply: (1) should an explicitly-specified
payload target bypass the protection branch (no re-match, no clone), or
is the pinned-edition check expected to run regardless; (2) would an
Info-level "imported to cloned book X because file matched edition Y"
log line make clone creation visible without debug logging — the clone
outcome is operator-indistinguishable from the #111-style duplicates,
and cleanup orphaned the mis-attached `BookFile` rows.

## Fix / workaround

- **No upstream fix yet.**
- Local remediation: re-point `BookFile.EditionId` via SQL to the
  intended edition, delete the duplicate book rows.
- Each repeated manual import of the same pinned-edition book spawns
  another clone row — worth avoiding until the bypass question is
  resolved.
- Recycle bin now enabled locally (2026-10-04) to make future import
  collateral reversible.

## References

- [Chaptarr #285](https://github.com/Chaptarr/chaptarr/issues/285)
- [Maintainer reply](https://github.com/Chaptarr/chaptarr/issues/285#issuecomment-5981361913) and [our confirmation reply](https://github.com/Chaptarr/chaptarr/issues/285#issuecomment-5984456691) (2026-10-04)
- [Chaptarr #111](https://github.com/Chaptarr/chaptarr/issues/111) — duplicate-row hijack on the tracked-download path ([digest](duplicate-row-import-hijack.md))
- [Chaptarr #262](https://github.com/Chaptarr/chaptarr/issues/262) — sibling-match wrong-book import ([digest](sibling-match-subtitle.md))
