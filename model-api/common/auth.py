"""Bearer-token auth dependency, shared by every backend.

Single static token, generated on first run (see config.get_or_create_api_token)
and compared with a constant-time comparison. Deliberately simple for a
single-user service; swap for a real token table if that ever changes.

Set MODEL_API_DISABLE_AUTH=1 to skip the check entirely -- e.g. for quick
browser-based verification over a connection you already trust (an
SSH-tunneled port on a private network, reachable only to whoever can SSH
in). Off by default: this is the only access control in front of the
service, and it also gates who can submit Slurm jobs under your account, so
leave it enabled for anything beyond a deliberate, temporary check.
"""

from __future__ import annotations

import hmac
import os

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from common import config

_bearer = HTTPBearer(auto_error=False)
AUTH_DISABLED = os.environ.get("MODEL_API_DISABLE_AUTH") == "1"


def require_token(credentials: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> None:
    if AUTH_DISABLED:
        return
    if credentials is None or not hmac.compare_digest(credentials.credentials, config.API_TOKEN):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid bearer token.",
            headers={"WWW-Authenticate": "Bearer"},
        )
