# Contributing

## Working agreements
- Keep business rules inside `packages/core/domain`.
- Route handlers and Streamlit pages stay thin.
- Prefer application services and ports over direct infrastructure access.
- Add or update tests with every behavioral change.

## Local workflow
1. Install dependencies with `make setup`.
2. Run `make lint`, `make typecheck`, and `make test`.
3. Start the API with `make run-api`.
4. Start the Streamlit client with `make run-streamlit`.

## Structure discipline
- `apps/`: UI and delivery layers.
- `packages/core/`: domain and use cases.
- `packages/infrastructure/`: concrete adapters.
- `packages/shared/`: truly cross-cutting utilities only.
