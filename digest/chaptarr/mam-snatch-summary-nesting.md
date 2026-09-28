# MAM account status refresh breaks after snatch_summary response nesting change

- **Project:** Chaptarr
- **Status:** fixed-upstream
- **Affects:** Chaptarr versions before the fix (confirmed broken on `develop` as of 2026-09-24, MAM API change happened same window)
- **Filed:** [Chaptarr PR #189](https://github.com/Chaptarr/chaptarr/pull/189) (fix + confirmation comment), merged into `develop` via commit `6446094`
- **Related notes:** —

## Symptom

MyAnonamouse (MaM) account status refresh in Chaptarr silently stops
updating. The log shows:

```
MAM user data response did not include a valid unsatisfied-torrent summary
```

The saved unsatisfied-slot status goes stale, and if `ProtectUnsatisfiedSlots`
is on (the default), Chaptarr starts refusing grabs based on stale data —
even though indexer searches still work fine and MaM itself is reachable.

## Cause

MaM changed their account-status API response shape: `created` and `unsat`
moved from the response root into a nested `snatch_summary` object.
Chaptarr's DTO (`MyAnonaMouse.cs`) still read them at the root, so both
fields came back empty, the refresh call threw its validation error, and
no snapshot was ever persisted — `unsatisfiedCount`/`unsatisfiedSnapshotUtc`
stayed null in the DB indefinitely.

Confirmed independently against a real deployment (Chaptarr 0.9.958.0,
`develop`, MaM over qBittorrent): calling `jsonLoad.php?snatch_summary`
directly showed the nested shape, matching the PR author's diagnosis
exactly.

**Gotcha for anyone testing a fix:** the refresh path only attempts once
per hour, and a *failed* attempt still counts as an attempt. Right after
deploying a build with the fix, a manual "Refresh account status" can
appear to do nothing for up to an hour — that's expected, not a sign the
fix didn't work. Cost real debugging time before reading the source
confirmed it.

## Fix / workaround

- **Fixed and merged** — PR #189 reads the nested `snatch_summary` when
  present and falls back to the old root-level shape otherwise, so it
  works against both API versions. Merged into `develop` via commit
  `6446094`.
- No workaround was needed once the fix shipped; before that, the only
  option was toggling `ProtectUnsatisfiedSlots` off (at the cost of losing
  the slot-protection safety net entirely).

## References

- [Chaptarr PR #189](https://github.com/Chaptarr/chaptarr/pull/189)
- [MaM's own announcement of the API change](https://www.myanonamouse.net/f/t/93313) (login required)
