from types import SimpleNamespace

import pytest

from packages.infrastructure.auth import supabase_auth_provider as provider_module
from packages.shared.auth_context import reset_access_token, set_access_token
from packages.shared.errors.base import AuthenticationError


class FakeAdminAuth:
    def __init__(self, user: object | None) -> None:
        self._user = user
        self.requested_tokens: list[str] = []

    def get_user(self, access_token: str) -> object:
        self.requested_tokens.append(access_token)
        return SimpleNamespace(user=self._user)


class FakeAdminClient:
    def __init__(self, user: object | None) -> None:
        self.auth = FakeAdminAuth(user)


class FakePublicAuth:
    def sign_in_with_password(self, _: dict[str, str]) -> object:
        raise AssertionError("sign_in_with_password should not be called in this test")

    def sign_up(self, _: dict[str, str]) -> object:
        raise AssertionError("sign_up should not be called in this test")


class FakePublicClient:
    def __init__(self) -> None:
        self.auth = FakePublicAuth()


def test_supabase_auth_provider_uses_demo_fallback_without_token() -> None:
    provider = provider_module.SupabaseAuthProvider(
        public_client=FakePublicClient(),
        admin_client=FakeAdminClient(user=None),
        allow_demo_fallback=True,
        bootstrap_user_id="demo-user",
        bootstrap_user_email="demo@vetapp.local",
    )

    user = provider.get_current_user()

    assert user.id == "demo-user"
    assert user.email == "demo@vetapp.local"


def test_supabase_auth_provider_requires_token_without_demo_fallback() -> None:
    provider = provider_module.SupabaseAuthProvider(
        public_client=FakePublicClient(),
        admin_client=FakeAdminClient(user=None),
        allow_demo_fallback=False,
    )

    with pytest.raises(AuthenticationError, match="Missing access token"):
        provider.get_current_user()


def test_supabase_auth_provider_resolves_bearer_token_user() -> None:
    admin_client = FakeAdminClient(user=SimpleNamespace(id="user-123", email="user@example.com"))
    provider = provider_module.SupabaseAuthProvider(
        public_client=FakePublicClient(),
        admin_client=admin_client,
        allow_demo_fallback=True,
        bootstrap_user_id="demo-user",
        bootstrap_user_email="demo@vetapp.local",
    )

    context_token = set_access_token("token-123")
    try:
        user = provider.get_current_user()
    finally:
        reset_access_token(context_token)

    assert user.id == "user-123"
    assert user.email == "user@example.com"
    assert admin_client.auth.requested_tokens == ["token-123"]
