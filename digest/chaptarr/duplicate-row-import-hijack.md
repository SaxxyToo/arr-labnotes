# Duplicate book rows with conflicting work IDs hijack grabbed imports

- **Project:** Chaptarr
- **Status:** filed (root cause); 2026-09-28 diagnostic comment posted on #111; two competing import-half fixes open, none merged
- **Affects:** confirmed as of 2026-09-27, re-audited 2026-09-28, likely present for longer
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

### Scale and evidence (2026-09-28 audit)

- 3,866 book rows; 95 duplicate groups / 226 rows. 55 groups (143 rows)
  have **non-intersecting** work IDs — 5 of those hold a monitored row
  (4 wanted/missing at audit time) — versus 1 of the 40 intersecting
  groups. The intersection check is what separates the dangerous
  inventory.
- 9 `bookImportIncomplete` rejections between 2026-09-23 and 2026-09-27,
  six of them on one night: one book rejected four times, three of those
  inside 18 minutes (each against its non-intersecting twin), two
  same-book snatches 20 seconds apart under different tracker torrent
  IDs, and three `downloadFailed` events alongside.
- With MaM unsatisfied slots saturated, the grab guard refused all grabs —
  the loop didn't just waste downloads, it stalled acquisition until the
  slot count came down.
- Detection query and full numbers: [comment on #111, 2026-09-28](https://github.com/Chaptarr/chaptarr/issues/111#issuecomment-5881275562).

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
- [Comment on #111 — refreshed scale, query, rejection history (2026-09-28)](https://github.com/Chaptarr/chaptarr/issues/111#issuecomment-5881275562)
- [Chaptarr PR #113](https://github.com/Chaptarr/chaptarr/pull/113)
- [Chaptarr #155](https://github.com/Chaptarr/chaptarr/issues/155)
- [Chaptarr #262](https://github.com/Chaptarr/chaptarr/issues/262) — sibling-match variant of the same stuck-import symptom (different code path; see [sibling-match-subtitle.md](sibling-match-subtitle.md))