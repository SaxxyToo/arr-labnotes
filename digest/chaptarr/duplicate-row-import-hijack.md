# Duplicate book rows with conflicting work IDs hijack grabbed imports

- **Project:** Chaptarr
- **Status:** filed (root cause), two competing import-half fixes open, none merged
- **Affects:** confirmed as of 2026-09-27, likely present for longer
- **Filed:** [Chaptarr#111](https://github.com/Chaptarr/chaptarr/issues/111) (root cause), [PR #113](https://github.com/Chaptarr/chaptarr/pull/113) and [#155](https://github.com/Chaptarr/chaptarr/issues/155) (competing import-half fixes)
- **Related notes:** —

## Symptom

A book gets grabbed and snatched from an indexer, but the import fails and
the book stays in a "wanted" state — so the *next* search grabs it again.
Repeated over days, this burns private-tracker download slots/ratio on a
book that's already been downloaded, sometimes 2-3x in under 20 minutes.

## Cause

Chaptarr's author-bibliography sync (`RefreshAuthorService.AddChildren`)
creates a separate `Books` row for the same title whenever it's matched
through a different provider edition ID (e.g. a Hardcover edition prefix
vs a GoodReads edition prefix). This produces two DB rows for what is
really one book.

When a duplicate pair's external work IDs (Hardcover/Goodreads/OpenLibrary)
**don't intersect**, Chaptarr's retarget-on-import rescue path
(`RetargetSameWorkMatchesToGrabbedBook`, gated on
`WorkIdMatcher.WorkProviderIdMatches`) declines to fix the mismatch. The
import is hard-rejected, the originally-grabbed row is never marked
downloaded, and it stays wanted — so the next search cycle grabs it again.

Duplicate rows whose work IDs *do* intersect are harmless; the retarget
logic handles those correctly. The conflicting-ID case is the dangerous
one, and it's silent — nothing in the UI flags which duplicates are safe
vs which are live landmines.

**Deleting the duplicate row does not fix it** — the next author refresh
re-creates it. This was independently confirmed by a second reporter in
the issue thread, not just us.

## Fix / workaround

- **No upstream fix merged yet.** Two competing PRs address the import
  half of the problem (#113, #155) but the row-creation half
  (`RefreshAuthorService.AddChildren` inserting every unlinked remote
  work as a new row) is unaddressed by either.
- **Working local mitigation:** unmonitor the looped row —
  `PUT /api/v1/book/monitor` with `{"bookIds":[<id>],"monitored":false}`.
  This stops it from being searched/grabbed again. Verify by confirming
  the id drops out of `/api/v1/wanted/missing`, not just by the API
  response code.
- Detecting which duplicate pairs are dangerous requires comparing work
  IDs directly (empty intersection = risk), not just matching on title.

## References

- [Chaptarr#111](https://github.com/Chaptarr/chaptarr/issues/111)
- [Chaptarr PR #113](https://github.com/Chaptarr/chaptarr/pull/113)
- [Chaptarr #155](https://github.com/Chaptarr/chaptarr/issues/155)
