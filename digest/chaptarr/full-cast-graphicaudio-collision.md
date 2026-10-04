# 'Full Cast' naming collapse + tag-dependent IsGraphicAudio detection make regular and dramatized editions path-identical

- **Project:** Chaptarr
- **Status:** filed
- **Affects:** Chaptarr 0.9.965.0 (Docker on Unraid, PostgreSQL backend; observed 2026-10-03)
- **Filed:** [Chaptarr #286](https://github.com/Chaptarr/chaptarr/issues/286) (filed 2026-10-04)
- **Related notes:** —

## Symptom

Two products of the same book (regular multi-narrator edition vs
dramatized/GraphicAudio edition) compute **identical destination
paths**, and the replace/upgrade path then **silently and permanently
deletes** whichever file sits at the destination — in both directions.
We lost a Golden Son GA Part 2 file (BookFile 3004) and a Dark Age GA
file (BookFile 1897); recycle bin was not configured, so the deletion
was unrecoverable through Chaptarr.

## Cause

Two mechanisms, maintainer-confirmed against `develop` e67374f:

1. **Naming collapse.** `FileNameBuilder.AddNarratorTokens` collapses
   any edition with more than two narrators to the literal
   `"Full Cast"`. Books whose *regular* edition is genuinely
   multi-narrator (Iron Gold, Dark Age) therefore compute the same
   folder/file path as their dramatized counterparts. The
   `graphicAudioSuffix` is appended only when `BookFile.IsGraphicAudio`
   is true.
2. **Tag-dependent flag.** `IsGraphicAudio` is set only from
   `DetectGraphicAudioFromLocalTags` (embedded tags) and title parsing
   at import time. A GA file whose tags don't advertise it imported
   with the flag false and computed the regular edition's path. Manual
   import is tag-only — it never examines the filename or folder — so
   `... - GraphicAudio.m4b` naming does not set the flag. The flag is
   not exposed on the BookFile API resource, so it can't be forced from
   the payload.

**Deletion is row-scoped, not path-based** (maintainer correction):
`replaceExistingFiles=true` on a manual import replaces *every* file on
the book regardless of path (L1070–1073); an automatic import replaces
files on the same edition unless the new file is lower quality. With
both files on one book row, distinct paths would **not** have prevented
the loss.

Log evidence confirms the first deletion was **automatic** (completed
download, not a manual import): `BookImportedEvent … NewDownload=True`
events at 2026-10-03 23:03–23:04 UTC with sources under
`/data/usenet/complete/`, and a `[IMPORT-PATH-CONFLICT]` warning showing
the occupied destination was explicitly detected ("Including every
displaced row in the atomic replacement") and replaced anyway. The
replacement also proceeded with `UpgradeAllowed=False` on the quality
profile — an open question raised in the reply: is that
`replaceExistingFiles` semantics winning over the profile, or should
the profile have blocked it?

## Fix / workaround

- **No upstream fix yet.** Three asks in the report: production-type-
  aware default naming tokens (or a conflict-on-different-production-
  type check instead of silent cross-product replace), upgrade-delete
  not removing a file that is not a prior copy of the same product,
  and `IsGraphicAudio` settable through the BookFile API resource /
  ManualImport payload.
- Local: recovered both files from out-of-pipeline sources (original
  torrent download dir; SABnzbd re-grab), set `IsGraphicAudio=true` via
  SQL, and Chaptarr's rename then moved them to distinct
  `… - GraphicAudio …` folders — confirming the suffix mechanism works
  and the missing flag was the trigger.
- Recycle bin enabled locally (2026-10-04, `/config/recycle-bin`,
  14-day cleanup) so future upgrade-deletes are reversible.

## References

- [Chaptarr #286](https://github.com/Chaptarr/chaptarr/issues/286)
- [Maintainer reply](https://github.com/Chaptarr/chaptarr/issues/286#issuecomment-5981362206) and [our reply with log evidence](https://github.com/Chaptarr/chaptarr/issues/286#issuecomment-5984497719) (2026-10-04)
- [Chaptarr #111](https://github.com/Chaptarr/chaptarr/issues/111) — duplicate-row hijack ([digest](duplicate-row-import-hijack.md))
