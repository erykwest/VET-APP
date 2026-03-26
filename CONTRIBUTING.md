# Contributing

## Working agreements
- Keep business rules inside `packages/core/domain`.
- Route handlers and Flutter widgets stay thin.
- Prefer application services and ports over direct infrastructure access.
- Add or update tests with every behavioral change.

## Local workflow
1. Install dependencies with `make setup`.
2. Run `make lint`, `make typecheck`, and `make test`.
3. Start the API with `make run-api`.
4. Start the Flutter web client with `cd apps/mobile_app && flutter pub get && flutter run -d chrome`.

## Structure discipline
- `apps/`: UI and delivery layers.
- `packages/core/`: domain and use cases.
- `packages/infrastructure/`: concrete adapters.
- `packages/shared/`: truly cross-cutting utilities only.
