## Access

**Base URL:** `{{base_url}}` for this response -- use whatever host and port you actually reach this
API on; there is no other fixed public URL documented here.

**Network reachability:** this API has no CORS configuration, so it isn't meant to be called
directly from a browser running on a different origin. It's built for server-to-server integration
(your backend calling this one directly), typically over a private network or a forwarded port --
it is not exposed on the open internet by default.

**Authentication:** {{auth_mode_line}} The scheme, when required, is a single static bearer token:
send `Authorization: Bearer <token>` on every request to a non-public endpoint. Always-open endpoints
that never need a token, on any deployment: `GET /v1/health`, `GET /v1/guide`, `/docs`, `/redoc`, and
`/openapi.json`.

A `401` response means either no token was sent or the one sent doesn't match -- there is currently
one shared token for the whole deployment, not a per-integration credential. Obtaining or rotating
that token is a server-operator action outside this API itself; ask whoever operates this
deployment for it rather than expecting a self-service signup flow.