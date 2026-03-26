# ADR 003: API First Even With Flutter

## Status
Accepted

## Decision
Organize the codebase as if multiple clients will consume the same use cases.

## Consequences
- Route handlers and Flutter widgets stay thin
- Application services become the stable entry point
- Future clients can be added without rewriting the core
