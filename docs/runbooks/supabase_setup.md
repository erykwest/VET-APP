# Supabase Setup

## Database connection
The repository is prepared to read Supabase Postgres details from `.env`.

Use these variables:
- `API_BASE_URL`
- `PERSISTENCE_BACKEND`
- `AUTH_BACKEND`
- `DATABASE_URL`
- `SUPABASE_DB_HOST`
- `SUPABASE_DB_PORT`
- `SUPABASE_DB_NAME`
- `SUPABASE_DB_USER`
- `SUPABASE_DB_PASSWORD`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `BOOTSTRAP_USER_ID`
- `BOOTSTRAP_USER_EMAIL`

Secret handling rules:
- keep real values only in local `.env`
- never commit `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_DB_PASSWORD`, or a populated `DATABASE_URL`
- `SUPABASE_ANON_KEY` is client-safe, but still keep it out of the repo-local `.env.example`
- when `AUTH_BACKEND=supabase`, `BOOTSTRAP_USER_ID` and `BOOTSTRAP_USER_EMAIL` are ignored

Current project values already prepared in `.env.example`:
- host: `aws-1-eu-west-1.pooler.supabase.com`
- port: `5432`
- database: `postgres`
- user: `postgres.ywbuzgwbkrmkukkpysbz`

## Current bootstrap mode
- `PERSISTENCE_BACKEND=supabase` enables Supabase repositories
- `AUTH_BACKEND=supabase` enables real Supabase email/password auth and bearer-token user resolution
- `ALLOW_DEMO_AUTH_FALLBACK=true` keeps the demo user available when the frontend is still in bypass-login mode and no bearer token is present
- `API_BASE_URL` switches the Flutter client from local preview entry to the app shell that talks to the Python API

Fail-fast validation:
- if `PERSISTENCE_BACKEND=supabase`, the app now requires `DATABASE_URL`, `SUPABASE_URL`, and `SUPABASE_SERVICE_ROLE_KEY`
- if `AUTH_BACKEND=supabase`, the app now requires `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`

## Schema to apply
Run the SQL in `scripts/setup/supabase_schema.sql` inside the Supabase SQL editor before starting the app with the Supabase backend.

If your Supabase project already had the older MVP schema applied, run the incremental migration in `scripts/setup/migrations/20260330_clinical_records.sql` too.

The script now includes:
- base tables
- indexes
- Row Level Security
- owner-scoped policies for `pet_profiles`, `conversations`, `reminders`, and `clinical_documents`
- cartella clinica fields on `pet_profiles`: `birth_date`, `weight_kg`, `microchip_code`, `neutered`
- `clinical_documents` for the first cartella clinica rollout

For the LLM evidence layer, also run `scripts/setup/supabase_llm_sources_schema.sql`.

That schema adds:
- a curated registry of trusted domains and base URLs
- external ranking registries with normalized scores
- a catalog of approved source documents with trust metadata
- vector-ready chunks for retrieval
- an audit table for tracking which sources were used in answers
- RPC-ready SQL functions such as `ai.rank_source_documents(...)` and `ai.match_source_chunks(...)`

Policy model:
- users can only read/update/delete rows where `owner_id = auth.uid()::text`
- insert on `conversations` and `reminders` is allowed only if the referenced pet belongs to the same authenticated user

## Implemented integration points
- `packages/infrastructure/persistence/supabase/`
- `packages/infrastructure/auth/supabase_auth_provider.py`
- `packages/bootstrap/container.py`

## Next step after schema
When the tables exist, start the app normally. The bootstrap container will use Supabase repositories and Supabase auth automatically from `.env`.

For the frontend/API bootstrap path, keep the client in bypass-login mode and point it at the Python backend:
- set `API_BASE_URL` in the Flutter runtime config
- keep `DEMO_BYPASS_AUTH=true` in the Flutter runtime config
- keep `AUTH_BACKEND=bootstrap` on the Python API, or keep `ALLOW_DEMO_AUTH_FALLBACK=true` when the backend auth mode is still `supabase`
- keep `PERSISTENCE_BACKEND=supabase` on the Python API

Recommended local commands for the persistent demo path:
- `make run-api`
- `make run-web-server-persistent-demo`

To seed stable demo data directly into Supabase and immediately verify readback on the same tables, run:
- `python scripts/setup/seed_demo_supabase.py --reset`

What this script does:
- uses `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` from local `.env`
- seeds `pet_profiles`, `conversations`, `reminders`, and `clinical_documents` for `BOOTSTRAP_USER_ID` by default
- re-reads the same rows from Supabase and prints a JSON summary with counts and pet names

Current scope:
- this validates the core Python persistence path against real Supabase tables
- Flutter preview sections that still rely on local seed stores remain outside this seed flow until their repositories are aligned to the same schema

For the LLM path, the recommended flow is:
- import journal rankings into registry tables and normalize them to percentiles
- curate allowed hosts in `ai.trusted_source_domains`
- ingest only documents that belong to those hosts into `ai.source_documents`
- chunk and embed only approved text marked `eligible_for_rag = true`
- call `ai.rank_source_documents(...)` first, then `ai.match_source_chunks(...)` before sending context to Groq

Recommended backend toggle:
- `EVIDENCE_BACKEND=in_memory` for preview mode
- `EVIDENCE_BACKEND=supabase` when the RPC-backed evidence retriever is enabled

Initial registry seed workflow:
- run the schema SQL first
- dry-run the registry seed with `python scripts/setup/seed_source_registry.py`
- apply it with `python scripts/setup/seed_source_registry.py --apply`
- optionally import curated registry snapshots with `--snapshot-json path/to/export.json`
