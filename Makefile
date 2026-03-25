PYTHON ?= python
UV ?= uv

setup:
	$(UV) sync --all-extras

format:
	$(UV) run ruff format .

lint:
	$(UV) run ruff check .

typecheck:
	$(UV) run mypy apps packages tests

test:
	$(UV) run pytest

run-api:
	$(UV) run uvicorn apps.api.main:app --reload

run-streamlit:
	$(UV) run streamlit run apps/streamlit_app/app.py
