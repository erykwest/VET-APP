$ErrorActionPreference = "Stop"
uv run uvicorn apps.api.main:app --reload
