from typing import Any

from packages.core.application.ports.auth_provider import AuthProvider, AuthSession, AuthenticatedUser
from packages.shared.auth_context import get_access_token
from packages.shared.errors.base import AuthenticationError


class SupabaseAuthProvider(AuthProvider):
    def __init__(
        self,
        public_client: Any,
        admin_client: Any,
        *,
        allow_demo_fallback: bool = False,
        bootstrap_user_id: str = "",
        bootstrap_user_email: str = "",
    ) -> None:
        self._public_client = public_client
        self._admin_client = admin_client
        self._allow_demo_fallback = allow_demo_fallback
        self._bootstrap_user_id = bootstrap_user_id
        self._bootstrap_user_email = bootstrap_user_email

    def get_current_user(self) -> AuthenticatedUser:
        access_token = get_access_token()
        if not access_token:
            if self._allow_demo_fallback and self._bootstrap_user_id.strip():
                return AuthenticatedUser(
                    id=self._bootstrap_user_id,
                    email=self._bootstrap_user_email,
                )
            raise AuthenticationError("Missing access token")

        response = self._admin_client.auth.get_user(access_token)
        user = getattr(response, "user", None)
        if user is None:
            raise AuthenticationError("Invalid access token")

        return AuthenticatedUser(id=user.id, email=user.email or "")

    def sign_in_with_password(self, email: str, password: str) -> AuthSession:
        response = self._public_client.auth.sign_in_with_password({"email": email, "password": password})
        return self._map_auth_session(response)

    def sign_up(self, email: str, password: str) -> AuthSession | None:
        response = self._public_client.auth.sign_up({"email": email, "password": password})
        session = self._extract_session(response)
        if session is None:
            return None
        return self._map_auth_session(response)

    def _map_auth_session(self, response: Any) -> AuthSession:
        session = self._extract_session(response)
        user = getattr(response, "user", None)
        if session is None or user is None:
            raise AuthenticationError("Supabase did not return a valid session")

        return AuthSession(
            access_token=session.access_token,
            refresh_token=getattr(session, "refresh_token", None),
            user=AuthenticatedUser(id=user.id, email=user.email or ""),
        )

    @staticmethod
    def _extract_session(response: Any) -> Any | None:
        return getattr(response, "session", None)
