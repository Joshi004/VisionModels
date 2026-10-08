## Changelog

Dates are when a change shipped on this codebase, not necessarily when you're reading this -- the
`api_version` field (`GET /v1/guide?format=json`) is this server's own current version; compare it
against what you last integrated against.

- **0.4.0** (2026-10-08): Removed authentication entirely. No endpoint requires an `Authorization`
  header any more, so no endpoint returns `401`, and `GET /v1/guide?format=json` no longer has a
  `facts.auth` object. Clients that still send an `Authorization` header are unaffected -- it is
  simply ignored.
- **0.3.0** (2026-10-05): Added a fourth backend, Parakeet speech transcription
  (`POST /v1/parakeet/transcribe`) -- transcribes an existing recording (or a video's audio track)
  to text, with word- and segment-level timestamps; replaces that model's previous dedicated
  always-on service, which held a GPU permanently regardless of whether a request was in flight.
  Declared the `Transcription` tag. Documented `application/json` as a content type
  `GET /v1/jobs/{job_id}/result` can return (the transcript itself, for a transcription job).
- **0.2.0** (2026-10-04): Added this guide (`GET /v1/guide`). Documented the `401` response on every
  endpoint that can return it (previously only shown when a deployment happened to require a token
  at the time its docs were generated). Documented every content type `GET /v1/jobs/{job_id}/result`
  can actually return (previously only `video/mp4`/`audio/wav` were listed; voice-conversion and
  batch jobs also return `audio/mpeg`, `audio/flac`, `audio/ogg`, and `application/zip`). Declared
  the `Voice conversion` tag (the RVC endpoints already used it, but it was missing from this API's
  own tag list). Reworded endpoint descriptions throughout for an external reader -- removed
  references to this deployment's own internal file paths, scripts, and command names that a
  third-party caller has no access to and doesn't need.
- **0.1.0**: Initial tagged version (LTX-2.3, Wan-Animate v1, RVC voice conversion, and the shared
  job-tracking/upload infrastructure all three sit on).