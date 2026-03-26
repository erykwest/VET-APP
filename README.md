# Vet App

Flutter-first pet-tech product with a Python backend bootstrap. The repository is set up to show a convincing mobile demo first, while keeping the core ready for APIs, Supabase, and multiple LLM providers.

## Goals
- validate onboarding, auth, home, pet profile, chat, records, and reminders in a single mobile flow
- keep domain and application logic independent from delivery frameworks
- make the Flutter client the primary demo surface without coupling the core to it

## Repository shape
- `apps/mobile_app`: Flutter client and demo surface
- `apps/api`: FastAPI delivery layer
- `packages/core`: domain and application layers
- `packages/infrastructure`: concrete adapters
- `packages/shared`: config, errors, shared types
- `tests`: unit, integration, contract, e2e
- `docs`: architecture notes, ADRs, runbooks, product references

## Quickstart
1. Install `uv` or use `python -m pip install -e .[dev]` as fallback.
2. Copy `.env.example` to `.env`.
3. Choose one backend pair:
   - `AUTH_BACKEND=bootstrap` and `PERSISTENCE_BACKEND=in_memory` for local demo mode
   - `AUTH_BACKEND=supabase` and `PERSISTENCE_BACKEND=supabase` for real Supabase mode
4. Keep `LLM_PROVIDER=echo` for local demo runs. Switch to `LLM_PROVIDER=groq` only when you want to exercise the hosted LLM path and have set `LLM_API_KEY`.
5. Install dependencies with `make setup`.
6. Start the API with `make run-api`.
7. Start the Flutter client with `cd apps/mobile_app && flutter pub get && flutter run`.

## Main commands
- `make format`
- `make lint`
- `make typecheck`
- `make test`
- `make run-api`
- `make run-mobile`

## Vercel deploy
The repository is ready to deploy the FastAPI app on Vercel.

1. Import the repository into Vercel.
2. Keep the project root at the repository root.
3. Configure the required environment variables in the Vercel dashboard.
4. Deploy: Vercel will use the root `app.py` entrypoint and route requests to the FastAPI app.

For demo deployments, use:
- `AUTH_BACKEND=bootstrap`
- `PERSISTENCE_BACKEND=in_memory`
- `LLM_PROVIDER=echo`

For production-like deployments with Supabase, also configure the Supabase and LLM secrets described below.

## Environment variables
Configuration is centralized in `packages/shared/config/settings.py`. The bootstrap expects:
- `ENVIRONMENT`
- `APP_NAME`
- `API_HOST`
- `API_PORT`
- `DATABASE_URL`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_DB_HOST`
- `SUPABASE_DB_PORT`
- `SUPABASE_DB_NAME`
- `SUPABASE_DB_USER`
- `SUPABASE_DB_PASSWORD`
- `LLM_PROVIDER`
- `LLM_MODEL`
- `LLM_API_KEY`
- `LOG_LEVEL`
- `ENABLE_TELEMETRY`

When Supabase mode is enabled, the app now fails fast at startup if the required auth or persistence secrets are missing.

See `docs/runbooks/vercel_deploy.md` for the deployment checklist.

## Architecture notes
- Flutter is the primary demo client.
- FastAPI routes stay thin and delegate to application services.
- Domain models do not depend on Streamlit, FastAPI, or external providers.
- In-memory adapters keep the bootstrap runnable while Supabase/Postgres adapters are prepared as extension points.
- LLM integration is still a demo stub in this first bootstrap push.
- Supabase auth flow is now wired for runtime email/password login and bearer-token user resolution.
- Supabase persistence tables are protected by RLS owner-based policies.
- Local runtime should use `AUTH_BACKEND=bootstrap`, `PERSISTENCE_BACKEND=in_memory`, and `LLM_PROVIDER=echo` until the Supabase and Groq paths are intentionally enabled.

## Product source material
Product and strategy documents now live under `docs/`:
- `docs/product/`
- `docs/llm/`
- `docs/architecture/overview.md`
- `docs/architecture/repo_bootstrap_instructions.md`
- `docs/decisions/*`
- `docs/runbooks/flutter_mobile_setup.md`
- `docs/runbooks/local_development.md`
- `docs/runbooks/supabase_setup.md`
