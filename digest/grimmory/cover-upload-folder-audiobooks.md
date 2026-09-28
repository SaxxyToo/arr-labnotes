# Grimmory cover upload fails for folder-based audiobooks (500)

- **Project:** Grimmory (surfaced via Chaptarr connector PR)
- **Status:** pr-open (Chaptarr side fixed and confirmed; Grimmory-side bug still open)
- **Affects:** Grimmory as of the PR #136 test window (2026-09-28)
- **Filed:** [Chaptarr PR #136](https://github.com/Chaptarr/chaptarr/pull/136) (retest comment documents the finding); not yet filed as its own Grimmory-side issue
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

- Chaptarr-side folder-matching fix (`benjitobz`, commit referenced in the
  PR #136 retest) is confirmed working on its own — verified with 44/44
  audiobooks matching Grimmory correctly.
- Grimmory-side cover-upload 500 is **not yet fixed**, and not yet filed
  as a standalone Grimmory issue (a decision on whether/how to file it
  was pending as of the last retest).
- No known workaround yet for folder-based audiobooks other than
  expecting the metadata push to fail non-fatally (once Grimmory makes it
  non-fatal) or converting to single-file audiobooks.

## References

- [Chaptarr PR #136](https://github.com/Chaptarr/chaptarr/pull/136)
