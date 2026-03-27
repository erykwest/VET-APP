from __future__ import annotations

import json
from dataclasses import dataclass
from types import SimpleNamespace
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from packages.shared.config.settings import Settings
from packages.shared.errors.base import AuthenticationError, ProviderError


@dataclass(frozen=True)
class SupabaseRestResponse:
    data: list[dict[str, Any]]


class SupabaseRestTableQuery:
    def __init__(self, client: "SupabaseRestClient", table: str) -> None:
        self._client = client
        self._table = table
        self._params: list[tuple[str, str]] = []
        self._body: Any | None = None
        self._method = "GET"
        self._headers: dict[str, str] = {}

    def select(self, columns: str) -> "SupabaseRestTableQuery":
        self._method = "GET"
        self._params.append(("select", columns))
        return self

    def eq(self, field: str, value: str) -> "SupabaseRestTableQuery":
        self._params.append((field, f"eq.{value}"))
        return self

    def limit(self, count: int) -> "SupabaseRestTableQuery":
        self._params.append(("limit", str(count)))
        return self

    def upsert(self, payload: dict[str, Any] | list[dict[str, Any]]) -> "SupabaseRestTableQuery":
        self._method = "POST"
        self._body = payload
        self._params.append(("on_conflict", "id"))
        self._headers["Prefer"] = "resolution=merge-duplicates,return=representation"
        return self

    def execute(self) -> SupabaseRestResponse:
        query = urlencode(self._params)
        path = f"/rest/v1/{self._table}"
        if query:
            path = f"{path}?{query}"
        payload = self._client.request_json(
            method=self._method,
            path=path,
            body=self._body,
            extra_headers=self._headers or None,
        )
        if isinstance(payload, list):
            data = [item for item in payload if isinstance(item, dict)]
        elif isinstance(payload, dict):
            data = [payload]
        else:
            data = []
        return SupabaseRestResponse(data=data)


class SupabaseRestAdminAuthApi:
    def __init__(self, client: "SupabaseRestClient") -> None:
        self._client = client

    def get_user(self, access_token: str) -> object:
        payload = self._client.request_json(
            method="GET",
            path="/auth/v1/user",
            extra_headers={"Authorization": f"Bearer {access_token}"},
        )
        if not isinstance(payload, dict):
            raise AuthenticationError("Invalid access token")
        return SimpleNamespace(user=SimpleNamespace(id=payload.get("id"), email=payload.get("email") or ""))


class SupabaseRestPublicAuthApi:
    def __init__(self, client: "SupabaseRestClient") -> None:
        self._client = client

    def sign_in_with_password(self, credentials: dict[str, str]) -> object:
        payload = self._client.request_json(
            method="POST",
            path="/auth/v1/token?grant_type=password",
            body=credentials,
        )
        return _map_auth_payload(payload)

    def sign_up(self, credentials: dict[str, str]) -> object:
        payload = self._client.request_json(
            method="POST",
            path="/auth/v1/signup",
            body=credentials,
        )
        return _map_auth_payload(payload)


class SupabaseRestClient:
    def __init__(self, *, base_url: str, api_key: str) -> None:
        self._base_url = base_url.rstrip("/")
        self._api_key = api_key
        self.auth = SupabaseRestAdminAuthApi(self)

    def table(self, table: str) -> SupabaseRestTableQuery:
        return SupabaseRestTableQuery(self, table)

    def request_json(
        self,
        *,
        method: str,
        path: str,
        body: Any | None = None,
        extra_headers: dict[str, str] | None = None,
    ) -> Any:
        data = None if body is None else json.dumps(body).encode("utf-8")
        headers = {
            "apikey": self._api_key,
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
        }
        if extra_headers:
            headers.update(extra_headers)

        request = Request(
            url=f"{self._base_url}{path}",
            data=data,
            headers=headers,
            method=method,
        )

        try:
            with urlopen(request, timeout=30) as response:
                payload = response.read().decode("utf-8")
        except HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            raise ProviderError(f"Supabase {method} {path} failed: {exc.code} {detail}") from exc
        except URLError as exc:
            raise ProviderError(f"Supabase {method} {path} failed: {exc.reason}") from exc

        if not payload.strip():
            return []
        return json.loads(payload)


class SupabaseRestPublicClient(SupabaseRestClient):
    def __init__(self, *, base_url: str, api_key: str) -> None:
        super().__init__(base_url=base_url, api_key=api_key)
        self.auth = SupabaseRestPublicAuthApi(self)


def build_supabase_client(settings: Settings) -> SupabaseRestClient:
    return SupabaseRestClient(
        base_url=settings.supabase_url,
        api_key=settings.supabase_service_role_key,
    )


def build_supabase_public_client(settings: Settings) -> SupabaseRestPublicClient:
    return SupabaseRestPublicClient(
        base_url=settings.supabase_url,
        api_key=settings.supabase_anon_key,
    )


def _map_auth_payload(payload: Any) -> object:
    if not isinstance(payload, dict):
        raise AuthenticationError("Supabase did not return a valid session")

    user_payload = payload.get("user")
    if not isinstance(user_payload, dict):
        raise AuthenticationError("Supabase did not return a valid session")

    session_payload = payload.get("session")
    session = None
    if isinstance(session_payload, dict):
        session = SimpleNamespace(
            access_token=session_payload.get("access_token", ""),
            refresh_token=session_payload.get("refresh_token"),
        )
    elif payload.get("access_token"):
        session = SimpleNamespace(
            access_token=payload.get("access_token", ""),
            refresh_token=payload.get("refresh_token"),
        )

    return SimpleNamespace(
        user=SimpleNamespace(
            id=user_payload.get("id", ""),
            email=user_payload.get("email") or "",
        ),
        session=session,
    )
