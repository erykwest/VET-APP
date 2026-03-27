# Vercel deployment

This project exposes the FastAPI application through the repository root `app.py`, which makes it compatible with the Vercel Python runtime.

## Recommended targets
- Founder demo preview: deploy the Flutter web client as a separate Vercel project rooted at `apps/mobile_app`.
- Deploy `apps/api` via the root `app.py` entrypoint.
- Keep the API deployment separate from the Flutter web preview.

## Flutter web preview
Use this for the founder demo and other visual review flows.

1. Import the Git repository into Vercel.
2. Create a dedicated project with root directory `apps/mobile_app`.
3. Keep the project as a preview deployment, not production.
4. Let Vercel use [apps/mobile_app/vercel.json](C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/vercel.json).
5. The build runs through [apps/mobile_app/scripts/vercel_build_flutter_web.sh](C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/scripts/vercel_build_flutter_web.sh) and outputs `build/web`.

Notes:
- No backend environment variables are required for the demo preview.
- The Flutter app already falls back to demo-safe auth, pet, chat, records, and reminders data when runtime config is empty.
- The preview should tell the core loop story first: onboarding, auth, pet profile, chat, and reminders.
- SPA rewrites are handled inside `apps/mobile_app/vercel.json`.
- For a real Supabase web-auth preview, add `SUPABASE_URL` and `SUPABASE_ANON_KEY` to the `apps/mobile_app` Vercel project. The Flutter build script forwards them as `--dart-define` values when present.

## API project
Use this as a second Vercel project only when you want the bootstrap backend online.

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
- `EVIDENCE_BACKEND=in_memory`
- `LLM_PROVIDER=echo`
- `ENABLE_TELEMETRY=false`

These keep the backend preview-safe. They do not replace the Flutter compile-time Supabase defines for the mobile_app project.

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
- For the founder demo, avoid coupling the preview deployment to backend services that are not required to tell the core-loop story.
