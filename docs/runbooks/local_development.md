# Local Development

1. Install `uv`, or use `python -m pip install -e .[dev]` if `uv` is unavailable.
2. Copy `.env.example` to `.env`.
3. Run `make setup`.
4. Run `make run-api`.
5. Run `make run-streamlit`.
6. Execute `make lint`, `make typecheck`, and `make test` before pushing.
