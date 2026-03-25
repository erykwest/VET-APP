# Architecture Overview

## Guiding shape
The repository starts as a modular monolith with a domain-oriented core and two delivery surfaces:
- `apps/streamlit_app` for fast MVP validation
- `apps/api` for HTTP exposure and future mobile/backend use

## Layering
1. `apps/*` handles UI and transport.
2. `packages/core/application` orchestrates use cases.
3. `packages/core/domain` holds entities and business rules.
4. `packages/infrastructure` provides concrete adapters.
5. `packages/shared` centralizes config and cross-cutting primitives.

## Request flow
`Streamlit/FastAPI -> application service -> domain models -> infrastructure ports/adapters`

This keeps Streamlit replaceable. A future Flutter client can call the API or an SDK without rewriting the core.

## Why modular monolith first
- Fast iteration for MVP validation
- Clear boundaries without microservice overhead
- Easier testing and local development
- Straight path to extract APIs and specialized modules later
