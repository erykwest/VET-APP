import pytest

from packages.bootstrap.container import reset_container


@pytest.fixture(autouse=True)
def clear_container_state() -> None:
    reset_container()
