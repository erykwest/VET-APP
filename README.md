# Vet App

Modular monolith Python bootstrap for an AI pet-tech product. The repository is structured to validate the MVP quickly with Streamlit while keeping the core ready for APIs, mobile clients, Supabase, and multiple LLM providers.

## Goals
- validate authentication, pet profile, chat, and reminders in a first MVP cycle
- keep domain and application logic independent from delivery frameworks
- prepare a clean path to FastAPI-first and future Flutter/mobile clients

## Repository shape
- `apps/streamlit_app`: Streamlit validation client
- `apps/api`: FastAPI delivery layer
- `packages/core`: domain and application layers
- `packages/infrastructure`: concrete adapters
- `packages/shared`: config, errors, shared types
- `tests`: unit, integration, contract, e2e
- `docs`: architecture notes, ADRs, runbooks, product references

## Quickstart
1. Install `uv` or use `python -m pip install -e .[dev]` as fallback.
2. Copy `.env.example` to `.env`.
3. Install dependencies with `make setup`.
4. Start the API with `make run-api`.
5. Start Streamlit with `make run-streamlit`.

## Main commands
- `make format`
- `make lint`
- `make typecheck`
- `make test`
- `make run-api`
- `make run-streamlit`

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

## Architecture notes
- Streamlit is treated as a temporary validation client.
- FastAPI routes stay thin and delegate to application services.
- Domain models do not depend on Streamlit, FastAPI, or external providers.
- In-memory adapters keep the bootstrap runnable while Supabase/Postgres adapters are prepared as extension points.
- LLM integration is still a demo stub in this first bootstrap push.
- Supabase auth flow is now wired for runtime email/password login and bearer-token user resolution.
- Supabase persistence tables are protected by RLS owner-based policies.

## Product source material
Product and strategy documents now live under `docs/`:
- `docs/product/`
- `docs/architecture/overview.md`
- `docs/architecture/repo_bootstrap_instructions.md`
- `docs/decisions/*`
- `docs/runbooks/local_development.md`
- `docs/runbooks/supabase_setup.md`
