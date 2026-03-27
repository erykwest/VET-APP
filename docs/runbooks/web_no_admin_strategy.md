# Flutter Web No-Admin Strategy

This runbook defines the default way to boot the Flutter demo when the terminal does not have administrator rights.

## Why this exists

On this machine, `flutter run -d chrome` can fail for environment reasons that are unrelated to the app itself:

- Puro may try to sync cache or create links outside the workspace.
- Flutter-managed Chrome profiles under `.dart_tool/` can remain locked after interrupted runs.
- build artifacts inside `apps/mobile_app/build/` can stay locked and block later launches.

None of these issues are required for the product demo. The app target is web-first, so we should prefer a browser workflow that stays inside user-space and does not depend on elevated operations.

## Default boot path

Use the web server target instead of the managed Chrome device:

1. Open a terminal in the repository root.
2. Run `make run-web-server`.
3. Wait for Flutter to print the local URL, typically `http://127.0.0.1:8080`.
4. Open that URL manually in the browser you already use.

This keeps the boot flow inside the current user session and avoids the Chrome-device profile that Flutter creates under `.dart_tool/chrome-device`.
It is also the safest path for the founder demo because it keeps the presentation focused on the core loop rather than on local toolchain quirks.

If you are validating real Supabase auth in the same browser flow, append the compile-time defines explicitly:

1. `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... -d web-server --web-hostname 127.0.0.1 --web-port 8080`
2. `flutter build web --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
3. The `make run-web-server-supabase` and `make build-web-supabase` targets do the same thing from the repository root when the variables are exported.

## Recommended SDK policy

Do not rely on a toolchain that may request elevation during cache sync.

Preferred order:

1. A standalone Flutter SDK unpacked in a user-writable folder.
2. Session-local `PATH` pointing to that SDK only for the current shell.
3. `flutter pub get`
4. `flutter run -d web-server`

If `puro` is the only installed SDK, treat it as a temporary fallback, not as the default demo path.

## User-space cleanup only

If a run fails, clean only files inside the workspace:

- `apps/mobile_app/build/`
- `apps/mobile_app/.dart_tool/flutter_build/`
- `apps/mobile_app/.dart_tool/chrome-device/`
- `apps/mobile_app/.dart_tool/hooks_runner/`

These folders are generated artifacts and can be removed without admin rights as long as no process is holding a lock on them.

## Recovery order

When the web demo does not start, use this order:

1. Stop any running Flutter or Chrome instance tied to the demo workspace.
2. Remove generated workspace artifacts listed above.
3. Run `flutter pub get`.
4. Run `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080`.
5. Open the printed URL manually in the browser.

Only if this fails again should we investigate app-level runtime errors.

## Build path for previews

When we need a shareable artifact and not a live dev session:

1. Run `flutter build web`.
2. Serve `apps/mobile_app/build/web/` with a simple static server in user-space.

This is also the preferred path for preview hosting and aligns with the product direction: web first now, mobile-ready later.
