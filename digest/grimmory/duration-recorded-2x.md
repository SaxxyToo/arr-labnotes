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

The doubling is format-specific, not content-specific — confirmed by
testing across a real folder-based audiobook library and correlating
every affected file against sample rate + channel count:

| Sample rate | Mono | Stereo |
|---|---|---|
| 22050 Hz | never doubled | **always doubled** |
| 24000 Hz | never doubled | **always doubled** |
| 44100 Hz | never doubled | never doubled |

The discriminator is exactly **stereo + (22050 Hz or 24000 Hz)** — every
other combination reads correctly. This points at a duration-calculation
defect in Grimmory's audio-duration reader (a jaudiotagger-derived
library) specifically for that sample-rate range in stereo, not a
per-book or per-encoder issue. Reproducing it with synthetic sine-tone
audio (no real speech content) at those exact parameters confirms it's
purely a function of the file's technical format, unrelated to what's
actually recorded in it.

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
