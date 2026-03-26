# Local Development

1. Install `uv`, or use `python -m pip install -e .[dev]` if `uv` is unavailable.
2. Copy `.env.example` to `.env`.
3. Set the local runtime defaults in `.env`:
   - `AUTH_BACKEND=bootstrap`
   - `PERSISTENCE_BACKEND=in_memory`
   - `LLM_PROVIDER=echo`
   - `LLM_API_KEY=` can stay empty in echo mode
4. Run `make setup`.
5. Run `make run-api`.
6. Run `make run-streamlit`.
7. Execute `make lint`, `make typecheck`, and `make test` before pushing.
