# Import matches a sibling book when the file title carries a subtitle the edition title lacks

- **Project:** Chaptarr
- **Status:** filed
- **Affects:** Chaptarr 0.9.965.0 (Docker, `chaptarr/chaptarr:develop`, PostgreSQL backend; reproduced 2026-09-28)
- **Filed:** [Chaptarr #262](https://github.com/Chaptarr/chaptarr/issues/262) (filed 2026-09-28)
- **Related notes:** —

## Symptom

A book file whose embedded title carries a subtitle that its own edition
title does not have silently imports as the **wrong book in the same
series**. Concretely: "The Primal Hunter 6: A LitRPG Adventure" resolves
to "The Primal Hunter, Vol. 1" — the series' book 6 lands on volume 1.

The manual-import response reports the wrong match with `rejections: []`,
so it's indistinguishable from a correct one (the reporting-side issue is
[#105](https://github.com/Chaptarr/chaptarr/issues/105)). The leftover is
the same stuck-import fingerprint as #111: the grab sits `importBlocked`
in the queue and never lands on the right book.

## Cause

The strict edition-eligibility pass rejects the correct edition with
`CONTAINMENT_FAILED` when the file title has extra trailing tokens. The
fallback then re-scores the remaining candidates with
`!stagedPreferredBookIds.Contains(...)` — which excludes the book Stage 2
had already identified — so the only surviving candidate is the edition
titled exactly as the bare series name, and it wins.

The trigger is the subtitle, not the series number: same file, same ASIN,
changing only `dc:title` flips the match (A/B table is in the issue).
Stage 2 itself gets it right — the correct book and its exact ASIN are
identified — so the wrong match happens inside `FileMatchingService`
containment, a different code path from #111's
`RetargetSameWorkMatchesToGrabbedBook` retarget logic.

**Diagnostics gap (may be worth fixing on its own):** the rejection reason
is invisible in production — `IFileMatchingService.TraceSink` is only
assigned in test fixtures and `NzbDrone.MatchBench`, so
`RecordCandidateRejection` writes to a sink that doesn't exist at runtime.
No log level exposes it; the `CONTAINMENT_FAILED` evidence only surfaced
by building MatchBench.

## Fix / workaround

- **No upstream fix yet.** Filed as #262 with a reproducible A/B and
  matcher traces; cross-referenced to #111, #105, #50, #236.
- No workaround beyond remediating the match manually.
- Uncertainty flagged in the report: the exact containment predicate that
  drops the evidence for `[..., 6, a, litrpg, adventure]` against
  `[..., 6]` isn't pinned yet; the interior-gap check in
  `TitleTokenAlignment.TryAlignStructural` looks like it should pass, so
  something upstream of it is losing the evidence.

## References

- [Chaptarr #262](https://github.com/Chaptarr/chaptarr/issues/262)
- [Chaptarr #111](https://github.com/Chaptarr/chaptarr/issues/111) — duplicate-row retarget path (different mechanism, same stuck-import symptom)
- [Chaptarr #105](https://github.com/Chaptarr/chaptarr/issues/105) — wrong matches reported with no rejections/confidence