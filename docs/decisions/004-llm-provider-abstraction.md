# ADR 004: LLM Provider Abstraction

## Status
Accepted

## Decision
Hide model providers behind an `LLMClient` port.

## Consequences
- Provider swapping remains localized
- Domain and application layers stay provider-agnostic
- Enables cost/performance optimization later
