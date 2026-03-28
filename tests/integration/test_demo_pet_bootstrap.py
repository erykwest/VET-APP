from fastapi.testclient import TestClient

from apps.api.main import app


def test_demo_user_gets_seeded_pet_profiles_when_none_exist() -> None:
    client = TestClient(app)

    response = client.get("/pets")

    assert response.status_code == 200
    rows = response.json()["pet_profiles"]
    assert len(rows) >= 2
    names = {row["name"] for row in rows}
    assert {"Moka", "Oliver"}.issubset(names)
