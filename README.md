# Vet App

Web-first pet-tech product with a Flutter client and a Python backend bootstrap. The repository is set up to show a controlled browser demo first, with a clear path for later Supabase and API expansion.

## Goals
- validate the core loop in a single web flow: onboarding, auth, pet profile, chat, and reminders
- keep domain and application logic independent from delivery frameworks
- keep the demo surface easy to show to a founder while avoiding unnecessary runtime dependencies

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
3. Choose the runtime mode before starting the app:
   - founder/demo-safe path:
     - `AUTH_BACKEND=bootstrap`
     - `PERSISTENCE_BACKEND=in_memory`
     - `EVIDENCE_BACKEND=in_memory`
     - `LLM_PROVIDER=echo`
   - real Supabase web auth:
     - export `SUPABASE_URL` and `SUPABASE_ANON_KEY`
     - pass them as Flutter `--dart-define` values when running or building the web client
4. Install dependencies with `make setup`.
5. Start the API with `make run-api`.
6. Start the Flutter web demo with `make run-web-server` for the safest browser flow, or use `make run-web-server-supabase SUPABASE_URL=... SUPABASE_ANON_KEY=...` when validating real Supabase auth.

## Main commands
- `make format`
- `make lint`
- `make typecheck`
- `make test`
- `make run-api`
- `make run-web`
- `make run-web-server`
- `make run-web-supabase`
- `make run-web-server-supabase`
- `make build-web`
- `make build-web-supabase`

For the demo-safe path, prefer `make run-web-server` and open the printed URL manually in your browser. This keeps the preview inside the current user session and avoids browser/profile issues that do not add value to the presentation. When validating real Supabase auth in web, use the `*-supabase` targets so Flutter receives the required compile-time `--dart-define` values.

## Vercel deploy
The repository supports two Vercel projects:

- `apps/mobile_app` for the founder demo preview as a Flutter web app
- repository root for the FastAPI bootstrap backend

1. Import the repository into Vercel.
2. For the web demo preview, set the project root to `apps/mobile_app`.
3. For the backend bootstrap, keep the project root at the repository root.
4. Configure the required environment variables only for the backend project.
5. If the Flutter web project should use Supabase auth, add `SUPABASE_URL` and `SUPABASE_ANON_KEY` to that Vercel project too.
6. Deploy.

For demo deployments, use:
- `AUTH_BACKEND=bootstrap`
- `PERSISTENCE_BACKEND=in_memory`
- `EVIDENCE_BACKEND=in_memory`
- `LLM_PROVIDER=echo`

For production-like deployments with Supabase, also configure the Supabase and LLM secrets described below.

## Environment variables
Configuration is centralized in `packages/shared/config/settings.py`. The bootstrap expects:
- `ENVIRONMENT`
- `APP_NAME`
- `API_HOST`
- `API_PORT`
- `DATABASE_URL`
- `EVIDENCE_BACKEND`
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
The Flutter web client reads Supabase credentials only from compile-time `--dart-define` values, not from the repository `.env` file.

See `docs/runbooks/vercel_deploy.md` for the deployment checklist.

## Architecture notes
- Flutter web is the primary demo client for the founder preview.
- FastAPI routes stay thin and delegate to application services.
- Domain models do not depend on Flutter, FastAPI, or external providers.
- In-memory adapters keep the bootstrap runnable while Supabase/Postgres adapters are prepared as extension points.
- LLM integration is still a demo stub in this first bootstrap push.
- Supabase auth flow is now wired for runtime email/password login and bearer-token user resolution.
- Supabase persistence tables are protected by RLS owner-based policies.
- Browser preview should use `AUTH_BACKEND=bootstrap`, `PERSISTENCE_BACKEND=in_memory`, and `LLM_PROVIDER=echo` until the Supabase and Groq paths are intentionally enabled.
- Real Supabase web runs should pass `SUPABASE_URL` and `SUPABASE_ANON_KEY` as Flutter `--dart-define` values.

## Product source material
Product and strategy documents now live under `docs/`:
- `docs/product/`
- `docs/llm/`
- `docs/architecture/overview.md`
- `docs/architecture/repo_bootstrap_instructions.md`
- `docs/decisions/*`
- `docs/runbooks/`
