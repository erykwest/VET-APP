# 08 — Codex Bootstrap Prompt

Di seguito un prompt base da dare a Codex per far generare la struttura iniziale del frontend.

---

## Prompt

Sei un senior Flutter engineer. Devi costruire la struttura iniziale di una web app veterinaria in Flutter, con approccio web-first, configurazione mobile-ready, architettura modulare e backend Supabase.

### Obiettivi
- creare una codebase Flutter pulita e scalabile
- organizzare il codice per feature
- separare presentation, domain e data layer
- predisporre l'integrazione con Supabase
- predisporre design system e router
- evitare scorciatoie da prototipo disordinato

### Vincoli
- non inserire business logic nei widget
- non usare Supabase direttamente nelle pagine
- non creare un monolite in `lib/`
- mantenere naming chiaro e coerente
- includere cartelle `app`, `core`, `design_system`, `features`, `shared`

### Struttura richiesta
- `lib/app/`
- `lib/core/`
- `lib/design_system/`
- `lib/features/auth/`
- `lib/features/onboarding/`
- `lib/features/home/`
- `lib/features/pets/`
- `lib/features/chat/`
- `lib/features/medical_records/`
- `lib/features/reminders/`
- `lib/features/profile/`
- `lib/features/settings/`
- `lib/shared/`
- `test/unit/`
- `test/widget/`
- `test/integration/`

### Per ogni feature
Crea sottocartelle:
- `data/datasources`
- `data/dtos`
- `data/mappers`
- `data/repositories`
- `domain/entities`
- `domain/repositories`
- `domain/usecases`
- `presentation/pages`
- `presentation/widgets`
- `presentation/controllers`
- `presentation/state`

### Output atteso
1. tree completo della repo
2. file placeholder essenziali
3. `main.dart`
4. `app.dart`
5. bootstrap iniziale
6. router base
7. theme base
8. file README per ogni feature con responsabilità del modulo

### Criteri di qualità
- codice leggibile
- import ordinati
- dipendenze minimali
- pronta estensione futura
- commenti solo dove aiutano davvero

### Prima milestone
Genera solo la struttura iniziale della repo e i file skeleton, senza implementare ancora la logica completa di business.

---

## Uso consigliato
Prima fai generare la struttura.
Poi, in task separati, fai implementare:
1. auth
2. app shell
3. design system base
4. pets
5. chat
6. medical records
7. reminders
