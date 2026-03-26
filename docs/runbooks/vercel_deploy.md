# Vercel deployment

This project exposes the FastAPI application through the repository root `app.py`, which makes it compatible with the Vercel Python runtime.

## Recommended target
- Deploy `apps/api` via the root `app.py` entrypoint.
- Do not deploy the legacy validation client on Vercel as the primary app target.

## Setup steps
1. Import the Git repository into Vercel.
2. Leave the project root unchanged: use the repository root.
3. Add the environment variables required by your chosen backend mode.
4. Deploy.

## Minimum demo variables
- `ENVIRONMENT=production`
- `APP_NAME=Vet App`
- `AUTH_BACKEND=bootstrap`
- `PERSISTENCE_BACKEND=in_memory`
- `LLM_PROVIDER=echo`
- `ENABLE_TELEMETRY=false`

## Supabase mode variables
If you enable Supabase-backed auth or persistence, also configure:
- `DATABASE_URL`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

## Groq mode variables
If you enable the hosted LLM path, also configure:
- `LLM_PROVIDER=groq`
- `LLM_MODEL`
- `LLM_API_KEY`
- `LLM_BASE_URL`

## Notes
- `vercel.json` rewrites all incoming paths to the FastAPI entrypoint so API routes such as `/health` keep working.
- Local `.env` files are not uploaded to Vercel. Configure secrets in the Vercel project settings.
- Healthcheck endpoint: `/health`
