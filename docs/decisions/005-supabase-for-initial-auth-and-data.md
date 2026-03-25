# ADR 005: Supabase For Initial Auth And Data

## Status
Accepted

## Decision
Prepare the repository for Supabase-backed auth and persistence in the first production-oriented phase.

## Consequences
- Initial bootstrap can run with in-memory adapters
- Future Supabase integration has a dedicated adapter area
- Data model remains Postgres-friendly
