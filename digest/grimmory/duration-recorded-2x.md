# Folder audiobook duration recorded at 2x actual length

- **Project:** Grimmory
- **Status:** filed
- **Affects:** stereo MP3s at 22.05/24 kHz, folder-based audiobooks, confirmed on the version current as of 2026-09-27
- **Filed:** [grimmory-tools/grimmory#2800](https://github.com/grimmory-tools/grimmory/issues/2800), parent discussion [#2777](https://github.com/grimmory-tools/grimmory/discussions/2777)
- **Related notes:** —

## Symptom

A folder-based audiobook made of stereo MP3s at 22.05 kHz or 24 kHz sample
rate gets its total length recorded by Grimmory as roughly **double** the
actual playback duration (e.g. a 60-second file reads as 120 seconds).

## Cause

Root cause not fully documented in this repo yet beyond what's in the
filed issue — see #2800 for the reproduction detail. The bug is
reproducible with synthetic sine-tone audio, meaning it's a duration
calculation issue for this specific format combination (stereo + one of
those two sample rates), not a content-dependent bug.

## Fix / workaround

- **No fix shipped yet** — issue is open, no assigned label/type because
  a non-member GitHub token can't apply labels to its own filed issue
  (only maintainers can label it).
- Reproduction samples were published as CC0 synthetic files specifically
  so the maintainer could verify without needing real (and possibly
  copyrighted) audiobook files: see
  [SaxxyToo/grimmory-duration-repro](https://github.com/SaxxyToo/grimmory-duration-repro)
  — 4 sine-tone MP3s, byte-identical to the files used to reproduce the
  bug, fetchable unauthenticated.

## References

- [grimmory#2800](https://github.com/grimmory-tools/grimmory/issues/2800)
- [Discussion #2777](https://github.com/grimmory-tools/grimmory/discussions/2777)
- [Reproduction files](https://github.com/SaxxyToo/grimmory-duration-repro)
