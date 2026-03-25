import os

import pytest

from packages.bootstrap.container import reset_container
from packages.shared.config.settings import reset_settings

os.environ["AUTH_BACKEND"] = "bootstrap"
os.environ["PERSISTENCE_BACKEND"] = "in_memory"
os.environ["BOOTSTRAP_USER_ID"] = "demo-user"
os.environ["BOOTSTRAP_USER_EMAIL"] = "demo@vetapp.local"


@pytest.fixture(autouse=True)
def clear_container_state() -> None:
    reset_settings()
    reset_container()
