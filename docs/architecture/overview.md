# Architecture Overview

## Guiding shape
The repository starts as a modular monolith with a domain-oriented core and two delivery surfaces:
- `apps/mobile_app` for the primary Flutter web demo surface and the mobile-ready release path
- `apps/api` for HTTP exposure and future mobile/backend use

## Layering
1. `apps/*` handles UI and transport.
2. `packages/core/application` orchestrates use cases.
3. `packages/core/domain` holds entities and business rules.
4. `packages/infrastructure` provides concrete adapters.
5. `packages/shared` centralizes config and cross-cutting primitives.

## Request flow
`Flutter/FastAPI -> application service -> domain models -> infrastructure ports/adapters`

This keeps the UI replaceable. A future client can call the API or an SDK without rewriting the core, whether the frontend is served in the browser or on mobile.

## Why modular monolith first
- Fast iteration for MVP validation
- Clear boundaries without microservice overhead
- Easier testing and preview iteration
- Straight path to extract APIs and specialized modules later
