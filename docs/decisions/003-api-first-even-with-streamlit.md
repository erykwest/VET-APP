# ADR 003: API First Even With Streamlit

## Status
Accepted

## Decision
Organize the codebase as if multiple clients will consume the same use cases.

## Consequences
- Route handlers and UI stay thin
- Application services become the stable entry point
- Future Flutter/mobile adoption is simplified
