# Repo Bootstrap Instructions

## Decisione architetturale iniziale

**Scelta: partire con Flutter web come client principale, con mobile-ready configuration per release successive.**

### Motivazione
- L'obiettivo iniziale del progetto e' una demo web credibile, rapida da mostrare e facile da iterare.
- La UI iniziale deve servire a validare il loop di interazione con onboarding, autenticazione, profilo pet, chat, record e reminder.
- La repository deve restare _backend/domain first_ e non _UI first_.

### Vincolo fondamentale
Flutter web e' il client di validazione principale, ma la repository deve restare pensata per sostituire o affiancare il frontend senza toccare il core.

Questo significa:
- Flutter web e' il client di validazione principale.
- Tutta la logica di dominio deve vivere fuori dalla UI.
- La UI non deve contenere business logic.
- L'architettura deve rendere semplice aggiungere in futuro API pubbliche o private e moduli come reminder, documenti clinici, billing, marketplace e rete veterinaria.

## Obiettivo della repository

Costruire una repository monorepo modulare per un prodotto AI pet-tech con:
- sviluppo rapido nel primo ciclo
- separazione netta tra interfacce, dominio, integrazioni e infrastruttura
- facilitazione dell'evoluzione futura
- basso attrito per Codex
- testabilita'
- standard coerenti

## Principi architetturali obbligatori

1. Separation of concerns
2. API-first mindset
3. Framework-agnostic core
4. Ports and adapters
5. Modular monolith first
6. Typed Python
7. Testability by design
8. Configuration over hardcoding
9. Secure by default
10. Future-proof naming

## Struttura target

```text
repo-root/
├─ apps/
│  ├─ mobile_app/
│  └─ api/
├─ packages/
│  ├─ core/
│  ├─ infrastructure/
│  └─ shared/
├─ tests/
├─ docs/
├─ scripts/
├─ .env.example
├─ pyproject.toml
├─ Makefile
├─ README.md
└─ CONTRIBUTING.md
```

## Regole per le aree principali

- `apps/mobile_app`: client principale per demo web, onboarding, auth, home, pets, chat, records e reminders, con mobile-ready config per release successive.
- `apps/api`: strato di esposizione HTTP per client interni ed evoluzione futura.
- `packages/core/domain`: cuore del prodotto, senza dipendenze dalla UI o da SDK esterni.
- `packages/core/application`: orchestrazione dei casi d'uso e interfacce verso infrastruttura.
- `packages/infrastructure`: implementazioni concrete delle porte applicative.
- `packages/shared`: componenti trasversali veramente condivisi.

## Quality gates

- formatting e lint con ruff
- type check con mypy
- test con pytest
- CI GitHub Actions su PR e push a main

## Documentation requirements

- `README.md`: scopo del progetto, struttura repo, stack, quickstart web preview, variabili ambiente, comandi principali
- `docs/architecture/overview.md`: layer architetturali, flusso Flutter/API -> application -> domain -> infrastructure, motivazione modular monolith
- `docs/decisions/`: ADR iniziali aggiornate al client Flutter-first

## Flussi da supportare nella prima iterazione

1. autenticazione
2. profilo pet
3. chat base
4. reminder base

## Convenzioni per estensioni future

- client Flutter web gia' presente e in evoluzione
- introduzione FastAPI come backend principale
- moduli documenti clinici / PDF
- retrieval da basi scientifiche
- reminder scheduler asincrono
- billing/subscription
- ruoli veterinario / utente finale / admin
- audit trail e observability avanzata

## Istruzione finale

Implementa la repository come **modular monolith Python, API-first, domain-oriented, con Flutter web come client temporaneo di validazione principale**.
