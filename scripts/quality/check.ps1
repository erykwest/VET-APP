$ErrorActionPreference = "Stop"
uv run ruff check .
uv run mypy apps packages tests
uv run pytest
