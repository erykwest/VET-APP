# VET APP Mobile

Flutter client for the VET APP product.

## Goals

- mobile-first experience for pet owners
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

1. Install Flutter and Android Studio.
2. Run `flutter doctor`.
3. From `apps/mobile_app`, run `flutter pub get`.
4. Run `flutter run`.

## Current scope

The app is bootstrapped with:

- global theme tokens
- onboarding welcome screen
- placeholder routes for auth and home

## Notes

This app is intentionally lightweight for the first iteration. We can wire API, Supabase auth, and state management once the local Flutter toolchain is available.
