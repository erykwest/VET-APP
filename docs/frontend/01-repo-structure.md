# 01 — Repo Structure

## Struttura consigliata

```text
app_frontend/
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── .env.example
├── assets/
│   ├── icons/
│   ├── images/
│   ├── illustrations/
│   └── fonts/
├── docs/
│   ├── frontend/
│   │   ├── 00-project-overview.md
│   │   ├── 01-repo-structure.md
│   │   ├── 02-feature-modules.md
│   │   ├── 03-navigation-and-screens.md
│   │   ├── 04-design-system.md
│   │   ├── 05-supabase-integration.md
│   │   ├── 06-state-management-and-data-flow.md
│   │   ├── 07-mcp-workflow.md
│   │   └── 08-codex-bootstrap-prompt.md
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── bootstrap.dart
│   │   ├── router/
│   │   ├── theme/
│   │   └── di/
│   ├── core/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── extensions/
│   │   ├── utils/
│   │   ├── networking/
│   │   └── widgets/
│   ├── design_system/
│   │   ├── tokens/
│   │   ├── atoms/
│   │   ├── molecules/
│   │   ├── organisms/
│   │   └── layouts/
│   ├── features/
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── pets/
│   │   ├── chat/
│   │   ├── medical_records/
│   │   ├── reminders/
│   │   ├── profile/
│   │   └── settings/
│   ├── shared/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   └── main.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
└── tool/
    └── scripts/
```

## Regole
- `app/`: bootstrap dell'app, router, tema globale, dipendenze.
- `core/`: elementi trasversali, senza logica di business specifica.
- `design_system/`: componenti riutilizzabili e token visivi.
- `features/`: moduli funzionali isolati.
- `shared/`: modelli e repository condivisi fra più feature.
- `docs/`: documentazione operativa per team e AI agents.

## Convenzione per ogni feature
Ogni feature dovrebbe seguire questa struttura:

```text
features/<feature_name>/
├── data/
│   ├── datasources/
│   ├── dtos/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   └── value_objects/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── controllers/
│   └── state/
└── README.md
```

## Vantaggi
- evita dipendenze caotiche
- rende il codice leggibile anche per Codex
- semplifica test, refactor e parallelizzazione del lavoro
