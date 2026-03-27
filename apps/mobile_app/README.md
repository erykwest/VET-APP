# VET APP Web

Flutter client for the VET APP product.

## Goals

- web-first experience for pet owners
- reusable design system aligned with `docs/frontend/`
- clear separation between app shell, feature modules, and shared infrastructure
- smooth integration with the existing Python API and Supabase

## Structure

- `lib/app/`: bootstrap, router, theme
- `lib/core/`: app-wide constants and shared widgets
- `lib/design_system/`: tokens and reusable UI building blocks
- `lib/features/`: isolated product features
- `test/`: unit and widget tests

## First run

1. Install Flutter and make sure Chrome is available.
2. Run `flutter doctor`.
3. From `apps/mobile_app`, run `flutter pub get`.
4. Run `flutter run -d chrome`.

If you want the real Supabase auth path in web, pass the compile-time defines explicitly:

1. `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... -d chrome`
2. `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... -d web-server --web-hostname 127.0.0.1 --web-port 8080`
3. `flutter build web --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

If the terminal does not have administrator rights, prefer:

1. `flutter pub get`
2. `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080`
3. Open the printed URL manually in your browser

## Current scope

The app is bootstrapped with:

- global theme tokens
- onboarding welcome screen
- preview-friendly routes for auth and home
- explicit preview labels where data is still local or seeded

## Notes

This app is intentionally lightweight for the first iteration. We can wire API, Supabase auth, and state management while keeping the web path primary and mobile ready for later releases. Demo-safe runs should stay on local preview data; real Supabase runs need the `--dart-define` values above.

## Vercel preview

For the founder demo, this folder can be deployed as its own Vercel project:

1. Set the Vercel project root to `apps/mobile_app`.
2. Use the included [vercel.json](C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/vercel.json).
3. Vercel will run `npm run build`, which triggers `scripts/vercel_build_flutter_web.sh`.
4. The preview output is `build/web`.
5. If the preview should use Supabase auth, set the matching `SUPABASE_URL` and `SUPABASE_ANON_KEY` environment variables in the Vercel project so the build script can forward them to Flutter.

This keeps the Flutter web demo independent from the root FastAPI deployment and matches the current web-first roadmap.
