# Supabase Setup

## Database connection
The repository is prepared to read Supabase Postgres details from `.env`.

Use these variables:
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

Fail-fast validation:
- if `PERSISTENCE_BACKEND=supabase`, the app now requires `DATABASE_URL`, `SUPABASE_URL`, and `SUPABASE_SERVICE_ROLE_KEY`
- if `AUTH_BACKEND=supabase`, the app now requires `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`

## Schema to apply
Run the SQL in `scripts/setup/supabase_schema.sql` inside the Supabase SQL editor before starting the app with the Supabase backend.

The script now includes:
- base tables
- indexes
- Row Level Security
- owner-scoped policies for `pet_profiles`, `conversations`, and `reminders`

Policy model:
- users can only read/update/delete rows where `owner_id = auth.uid()::text`
- insert on `conversations` and `reminders` is allowed only if the referenced pet belongs to the same authenticated user

## Implemented integration points
- `packages/infrastructure/persistence/supabase/`
- `packages/infrastructure/auth/supabase_auth_provider.py`
- `packages/bootstrap/container.py`

## Next step after schema
When the tables exist, start the app normally. The bootstrap container will use Supabase repositories and Supabase auth automatically from `.env`.
