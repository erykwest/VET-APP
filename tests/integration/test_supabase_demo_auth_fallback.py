import os

from fastapi.testclient import TestClient

from apps.api.main import app
from packages.bootstrap.container import reset_container
from packages.shared.config.settings import reset_settings


def test_supabase_auth_backend_keeps_demo_bypass_without_bearer_token() -> None:
    original = {
        "AUTH_BACKEND": os.environ.get("AUTH_BACKEND"),
        "PERSISTENCE_BACKEND": os.environ.get("PERSISTENCE_BACKEND"),
        "ALLOW_DEMO_AUTH_FALLBACK": os.environ.get("ALLOW_DEMO_AUTH_FALLBACK"),
        "SUPABASE_URL": os.environ.get("SUPABASE_URL"),
        "SUPABASE_ANON_KEY": os.environ.get("SUPABASE_ANON_KEY"),
        "SUPABASE_SERVICE_ROLE_KEY": os.environ.get("SUPABASE_SERVICE_ROLE_KEY"),
        "BOOTSTRAP_USER_ID": os.environ.get("BOOTSTRAP_USER_ID"),
        "BOOTSTRAP_USER_EMAIL": os.environ.get("BOOTSTRAP_USER_EMAIL"),
    }
    os.environ["AUTH_BACKEND"] = "supabase"
    os.environ["PERSISTENCE_BACKEND"] = "in_memory"
    os.environ["ALLOW_DEMO_AUTH_FALLBACK"] = "true"
    os.environ["SUPABASE_URL"] = "https://example.supabase.co"
    os.environ["SUPABASE_ANON_KEY"] = "anon-key"
    os.environ["SUPABASE_SERVICE_ROLE_KEY"] = "service-role-key"
    os.environ["BOOTSTRAP_USER_ID"] = "demo-user"
    os.environ["BOOTSTRAP_USER_EMAIL"] = "demo@vetapp.local"
    reset_settings()
    reset_container()

    try:
        client = TestClient(app)

        response = client.get("/auth/me")

        assert response.status_code == 200
        assert response.json() == {
            "id": "demo-user",
            "email": "demo@vetapp.local",
        }
    finally:
        for key, value in original.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value
        reset_settings()
        reset_container()
