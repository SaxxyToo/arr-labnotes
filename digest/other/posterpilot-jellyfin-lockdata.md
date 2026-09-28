# PosterPilot: Jellyfin/Emby artwork applies don't set field locks (parity gap with Plex)

- **Project:** PosterPilot (not Chaptarr/Grimmory, but adjacent — poster/artwork management for Jellyfin among other media servers)
- **Status:** filed
- **Affects:** PosterPilot 0.13.1, confirmed against Jellyfin 12.1.0
- **Filed:** [diegopeixoto/posterpilot#121](https://github.com/diegopeixoto/posterpilot/issues/121)
- **Related notes:** —

## Symptom

On Plex, artwork PosterPilot applies gets its field locked (`lockField`)
so a later metadata-agent refresh can't silently overwrite it. The
Jellyfin/Emby code path (`src/lib/server/media-server/emby.ts`) doesn't do
this — it's currently a no-op. A library metadata refresh that pulls new
images can replace what PosterPilot just applied, with no warning.

## Cause

Feature parity gap, not really a "bug" — the Plex apply path implements
locking, the Jellyfin/Emby path was never built out to match. Jellyfin
and Emby both expose the equivalent mechanism: per-item `LockData`, which
takes a list of locked fields — adding `Images` to that list is a direct
analog of Plex's `lockField`.

## Fix / workaround

- **Not yet fixed** — filed as a feature request, not yet actioned.
  Offered to build and test the PR against a live Jellyfin instance.
- No workaround currently — expect a metadata refresh to potentially
  revert applied artwork on Jellyfin/Emby until this lands.

## References

- [posterpilot#121](https://github.com/diegopeixoto/posterpilot/issues/121)
