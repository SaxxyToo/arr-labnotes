# Grimmory cover upload fails for folder-based audiobooks (500)

- **Project:** Grimmory (surfaced via Chaptarr connector PR)
- **Status:** resolved on the Chaptarr side (2026-10-03 retest) — the connector now pushes audiobook covers to Grimmory's separate `audiobook-cover` slot, which does not hit this 500. No standalone Grimmory issue needed.
- **Affects:** Grimmory v3.5.0; the failing path was the generic `metadata/cover/upload` endpoint called with a folder-based audiobook
- **Filed:** [Chaptarr PR #136](https://github.com/Chaptarr/chaptarr/pull/136) — retest comments document the finding and the fix (branch head `8661bf2`)
- **Related notes:** —

## Symptom

Testing the Chaptarr↔Grimmory connector PR (#136): after a fix landed for
folder-matching (folder-based audiobooks now correctly match to Grimmory
books — 0 skips across 44 test books, up from partial matching before),
the per-book metadata push from Chaptarr to Grimmory still fails for
folder-based audiobooks specifically. Deterministic: 21/21 folder-based
audiobooks failed, 0/23 single-file audiobooks failed, in the same test
pass.

## Cause

`POST /api/v1/books/{id}/metadata/cover/upload` on the Grimmory side
returns HTTP 500 for folder-based audiobooks. Server-side
(`BookCoverService.writeCoverToBookFile`) throws `"File does not exist or
is not a regular file"` — it writes the storage cover and the folder's
`cover.jpg` successfully first, then throws when it tries to write the
cover *into* the audiobook file itself, because a folder-based audiobook
isn't a single file the way the writer expects.

The 500 aborts the whole per-book metadata push before other metadata
fields get applied — so it's not just a missing cover, it silently blocks
everything else in that push too.

## Fix / workaround

- Chaptarr-side folder-matching fix (`benjitobz`, `20863d3`) confirmed — 44/44 audiobooks match.
- **Fix (`benjitobz`, `e70499d`, branch head `8661bf2`):** Grimmory keeps a *separate*
  cover slot and endpoint for books whose primary file is an audiobook
  (`audiobook-cover` / `metadata/audiobook-cover/upload`). The connector now
  routes audiobook books there (`GrimmoryBook.CoverSlot`) and locks
  `audiobookCoverLocked` instead of `coverLocked`. Verified 2026-10-03: all 21
  folder-based audiobooks uploaded cleanly, `cover.jpg` written into each folder.
- **Fix (`benjitobz`, `8661bf2`):** cover upload is now caught per book — a cover
  failure warns and continues to the metadata write instead of aborting the book.
- **Residual (not a connector defect):** if a book's file is missing from disk
  (e.g. Grimmory 244 "Golden Son Part 2", empty folder), the `audiobook-cover`
  upload still returns 500 (`File does not exist or is not a regular file`). The
  non-fatal catch means metadata still lands; the cover simply doesn't.

## References

- [Chaptarr PR #136](https://github.com/Chaptarr/chaptarr/pull/136)
