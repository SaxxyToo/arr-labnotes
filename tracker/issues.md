# Tracker

Everything filed upstream, in one table. Status legend in the [README](../README.md).

| Project | # | Title | Status | Filed by | Notes |
|---|---|---|---|---|---|
| Chaptarr | [#111](https://github.com/Chaptarr/chaptarr/issues/111) | Duplicate book rows with conflicting work IDs hijack grabbed imports | filed | jbob06 | Root cause; see [digest](../digest/chaptarr/duplicate-row-import-hijack.md) |
| Chaptarr | [#113](https://github.com/Chaptarr/chaptarr/pull/113) | Import-half fix for #111 | pr-open | jbob06 | Competing with #155, neither merged as of 2026-09-27 |
| Chaptarr | [#155](https://github.com/Chaptarr/chaptarr/issues/155) | Import-half fix for #111 (alternate) | pr-open | JordanFromIT | See [digest](../digest/chaptarr/duplicate-row-import-hijack.md) |
| Chaptarr | [#136](https://github.com/Chaptarr/chaptarr/pull/136) | Grimmory connector: folder-matching + cover upload | pr-open | benjitobz | Folder-matching fix confirmed working; cover-upload 500 is a Grimmory-side blocker — see [digest](../digest/grimmory/cover-upload-folder-audiobooks.md) |
| Chaptarr | [#189](https://github.com/Chaptarr/chaptarr/pull/189) | Fix MAM account refresh after snatch_summary response change | fixed-upstream | jjbobzin | Independently confirmed + merged; see [digest](../digest/chaptarr/mam-snatch-summary-nesting.md) |
| Grimmory | [#2800](https://github.com/grimmory-tools/grimmory/issues/2800) | Folder audiobook length recorded as 2x actual duration | filed | SaxxyToo | Repro files at [grimmory-duration-repro](https://github.com/SaxxyToo/grimmory-duration-repro); see [digest](../digest/grimmory/duration-recorded-2x.md) |
| Grimmory | [discussion #2777](https://github.com/grimmory-tools/grimmory/discussions/2777) | (parent discussion for #2800) | filed | SaxxyToo | |
| PosterPilot | [#121](https://github.com/diegopeixoto/posterpilot/issues/121) | Jellyfin/Emby artwork applies don't set field locks (parity with Plex) | filed | SaxxyToo | Not a Chaptarr/Grimmory tool, but adjacent (Jellyfin artwork); see [digest](../digest/other/posterpilot-jellyfin-lockdata.md) |

## Adding a row

New entries go at the bottom of the relevant block, oldest-first within a
project. Link to a `digest/` entry for anything with real investigation
behind it — this table is an index, not the full story.
