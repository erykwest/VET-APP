# Istruzioni per Codex — Bootstrap della Repository

## Decisione architetturale iniziale

**Scelta: partire con Streamlit, non con Flutter, per il primo ciclo di sviluppo.**

### Motivazione
- L'obiettivo iniziale del progetto è un **MVP modulare**, rapido da testare, a basso costo e rivolto a test interni / early adopters.
- La UI iniziale deve servire soprattutto a **validare il loop di interazione** con autenticazione, profilo pet, chat e prime chiamate LLM.
- Nei documenti di progetto la prima fase è esplicitamente pensata con **Python + Streamlit**, mentre Flutter è una fase successiva, dopo la validazione del nucleo prodotto.
- Nella trascrizione founder emerge chiaramente che il sistema va costruito come **ecosistema modulare**, sviluppabile un pezzo alla volta senza rompere gli altri moduli.

### Vincolo fondamentale
**Anche se il primo client è Streamlit, la repository deve essere progettata fin da subito in modalità _backend/domain first_ e non _UI first_.**

Questo significa:
- Streamlit è solo il **client iniziale di validazione**.
- Tutta la logica di dominio deve vivere fuori dalla UI.
- La UI non deve contenere business logic.
- L'architettura deve rendere semplice aggiungere in futuro:
  - client Flutter/mobile
  - API pubbliche o private
  - moduli aggiuntivi (reminder, documenti clinici, billing, marketplace, rete veterinaria)

---

## Obiettivo della repository

Costruire una repository **monorepo modulare** per un prodotto AI pet-tech con queste caratteristiche:
- sviluppo rapido nel primo ciclo
- separazione netta tra interfacce, dominio, integrazioni e infrastruttura
- facilità di estensione futura
- basso attrito per Codex
- testabilità
- standard coerenti

La repo deve essere pronta per ospitare, nel tempo:
1. client Streamlit MVP
2. backend Python/API
3. moduli di dominio
4. provider LLM multipli
5. persistenza dati con Supabase/Postgres
6. future app Flutter
7. CI/CD, test, observability, billing, scheduler

---

## Principi architetturali obbligatori

Codex deve seguire questi principi senza eccezioni:

1. **Separation of concerns**
   - UI, application logic, domain logic, infrastructure e config devono stare in layer separati.

2. **API-first mindset**
   - Anche se all'inizio esiste solo Streamlit, il codice deve essere organizzato come se dovesse servire anche un client mobile.

3. **Framework-agnostic core**
   - Il core di dominio non deve dipendere da Streamlit, Supabase SDK o provider LLM specifici.

4. **Ports and adapters / hexagonal flavor**
   - Le integrazioni esterne devono entrare tramite interfacce/adapter, non direttamente nel dominio.

5. **Modular monolith first**
   - Niente microservizi all'inizio.
   - Un monolite modulare ben organizzato è la scelta corretta.

6. **Typed Python**
   - Usare type hints ovunque.
   - Validazione input/output con Pydantic.

7. **Testability by design**
   - Ogni servizio applicativo deve essere testabile in isolamento.

8. **Configuration over hardcoding**
   - Nessuna chiave, URL, provider o flag hardcoded.

9. **Secure by default**
   - Gestione segreti via environment variables.
   - Logging senza dati sensibili.

10. **Future-proof naming**
   - Evitare nomi troppo legati a Streamlit o a uno specifico provider AI.

---

## Stack iniziale richiesto

### Linguaggio e tooling
- Python 3.12+
- package manager: **uv** (preferito) oppure poetry
- lint/format: **ruff**
- type checking: **mypy**
- test: **pytest**
- settings: **pydantic-settings**

### Primo client
- Streamlit

### Backend / servizi
- Python
- FastAPI **predisposto** fin dall'inizio anche se non tutto verrà esposto subito

### Database / auth
- Supabase
- Postgres come modello dati di riferimento

### AI
- layer astratto LLM provider
- primo provider economico / base configurabile
- possibilità di swap futuro verso provider premium

---

## Struttura target della repository

Codex deve creare questa struttura di base:

```text
repo-root/
├─ .github/
│  └─ workflows/
│     ├─ ci.yml
│     └─ lint-and-test.yml
├─ apps/
│  ├─ streamlit_app/
│  │  ├─ app.py
│  │  ├─ pages/
│  │  ├─ components/
│  │  └─ view_models/
│  └─ api/
│     ├─ main.py
│     ├─ routes/
│     ├─ dependencies/
│     └─ schemas/
├─ packages/
│  ├─ core/
│  │  ├─ domain/
│  │  │  ├─ pet_profile/
│  │  │  ├─ conversation/
│  │  │  ├─ reminders/
│  │  │  ├─ knowledge/
│  │  │  └─ common/
│  │  ├─ application/
│  │  │  ├─ commands/
│  │  │  ├─ queries/
│  │  │  ├─ services/
│  │  │  └─ ports/
│  │  └─ contracts/
│  ├─ infrastructure/
│  │  ├─ persistence/
│  │  │  ├─ supabase/
│  │  │  ├─ postgres/
│  │  │  └─ models/
│  │  ├─ llm/
│  │  │  ├─ base/
│  │  │  ├─ providers/
│  │  │  └─ prompting/
│  │  ├─ auth/
│  │  ├─ storage/
│  │  ├─ logging/
│  │  └─ telemetry/
│  ├─ shared/
│  │  ├─ config/
│  │  ├─ errors/
│  │  ├─ utils/
│  │  └─ types/
│  └─ sdk/
│     └─ client/
├─ tests/
│  ├─ unit/
│  ├─ integration/
│  ├─ contract/
│  └─ e2e/
├─ docs/
│  ├─ architecture/
│  ├─ decisions/
│  ├─ product/
│  └─ runbooks/
├─ scripts/
│  ├─ dev/
│  ├─ setup/
│  └─ quality/
├─ .env.example
├─ pyproject.toml
├─ mypy.ini
├─ ruff.toml
├─ pytest.ini
├─ Makefile
├─ README.md
└─ CONTRIBUTING.md
```

---

## Regole per ogni area della repo

## 1. `apps/streamlit_app`
Scopo: client iniziale per validare UX, autenticazione, profilo pet e chat.

### Regole
- Nessuna business logic complessa dentro Streamlit.
- Nessuna chiamata diretta al provider LLM dai componenti UI.
- Nessuna query DB direttamente nelle pagine, salvo adapter dedicati.
- La UI deve chiamare solo servizi applicativi o API interne.

### Contenuti ammessi
- layout
- session state mapping
- input forms
- rendering output
- gestione feedback utente
- view models semplici

### Contenuti vietati
- regole di dominio
- prompt composition complessa
- logica di autorizzazione non centralizzata
- accesso ai segreti

---

## 2. `apps/api`
Scopo: strato di esposizione HTTP per client interni ed evoluzione futura.

### Regole
- Router sottili.
- Validazione con Pydantic.
- Nessuna business logic nei route handlers.
- Ogni endpoint delega a un application service.

### Prime route consigliate
- `/health`
- `/auth/me`
- `/pets`
- `/conversations`
- `/chat`
- `/reminders`

---

## 3. `packages/core/domain`
Scopo: cuore del prodotto.

### Deve contenere
- entità
- value objects
- regole di dominio
- invarianti
- eventi di dominio se utili

### Non deve contenere
- Streamlit
- FastAPI
- Supabase SDK
- chiamate HTTP
- librerie provider-specifiche

### Bounded contexts iniziali
Codex deve predisporre almeno questi moduli:
- `pet_profile`
- `conversation`
- `knowledge`
- `reminders`
- `common`

### Esempi di responsabilità
- `pet_profile`: dati pet, attributi sanitari, preferenze, contesto clinico di base
- `conversation`: messaggi, thread, turni, metadata, audit minimi
- `knowledge`: policy di retrieval, citazioni, provenienza conoscenza
- `reminders`: scadenze, ricorrenze, regole di notifica

---

## 4. `packages/core/application`
Scopo: orchestrazione dei casi d'uso.

### Deve contenere
- use cases
- command handlers
- query handlers
- services applicativi
- interfacce (`ports`) verso infrastruttura

### Pattern richiesto
Per ogni caso d'uso significativo usare un pattern del tipo:
- input model
- service/use case
- output model

### Esempi iniziali
- `register_user`
- `create_pet_profile`
- `update_pet_profile`
- `start_conversation`
- `send_chat_message`
- `list_conversations`
- `create_reminder`

---

## 5. `packages/infrastructure`
Scopo: implementazioni concrete delle porte applicative.

### Sezioni richieste
- `persistence/`
- `llm/`
- `auth/`
- `storage/`
- `logging/`
- `telemetry/`

### Regole
- ogni provider concreto deve stare dietro un'interfaccia
- nessun import da infrastructure dentro `domain`
- prompt templates separati dai servizi di dominio

### LLM provider layer
Codex deve creare:
- interfaccia astratta `LLMClient`
- provider base configurabile
- struttura pronta per provider multipli
- supporto a model selection tramite config

### Output minimo del layer LLM
- generazione risposta testuale
- metadata token/provider/model
- gestione errori / timeout
- hook per futura citazione fonti

---

## 6. `packages/shared`
Scopo: componenti trasversali veramente condivisi.

### Deve contenere
- config centralizzata
- eccezioni base
- helper minimali
- tipi condivisi

### Non deve diventare
- un contenitore generico di codice senza disciplina

Regola: se qualcosa è legato a un bounded context, deve stare nel bounded context, non in `shared`.

---

## Standard di naming

### Directory e file
- snake_case per file e package Python
- nomi espliciti e non abbreviati

### Classi
- PascalCase

### Funzioni e variabili
- snake_case

### Interfacce / porte
Usare suffissi chiari come:
- `Repository`
- `Gateway`
- `Client`
- `Provider`
- `Service`

### Esempi buoni
- `pet_profile_repository.py`
- `send_chat_message.py`
- `llm_client.py`
- `supabase_auth_provider.py`

### Esempi cattivi
- `helpers.py`
- `misc.py`
- `utils2.py`
- `final_service.py`

---

## Gestione configurazione

Codex deve centralizzare tutta la config in un modulo dedicato, ad esempio:

```text
packages/shared/config/
```

### Variabili da predisporre
- `ENVIRONMENT`
- `APP_NAME`
- `API_HOST`
- `API_PORT`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `LLM_PROVIDER`
- `LLM_MODEL`
- `LLM_API_KEY`
- `LOG_LEVEL`
- `ENABLE_TELEMETRY`

### Regole
- caricare settings con `pydantic-settings`
- fornire `.env.example`
- nessuna variabile letta in modo sparso nel codice

---

## Testing strategy obbligatoria

Codex deve predisporre test fin dal bootstrap.

### Tipologie
- `tests/unit/` per dominio e application
- `tests/integration/` per DB, auth, provider, API
- `tests/contract/` per adapter e interfacce
- `tests/e2e/` per flussi principali

### Priorità test iniziali
1. creazione profilo pet
2. invio messaggio chat
3. fallimento provider LLM
4. persistenza conversazione
5. autenticazione utente

### Regole
- test unitari senza dipendenze esterne
- uso di fake/in-memory repository dove possibile
- fixture riutilizzabili
- snapshot solo se strettamente necessari

---

## Quality gates

Codex deve configurare i seguenti controlli automatici:
- formatting/lint con ruff
- type check con mypy
- test con pytest
- CI GitHub Actions su PR e push a main

### Makefile target minimi
- `make setup`
- `make format`
- `make lint`
- `make typecheck`
- `make test`
- `make run-api`
- `make run-streamlit`

---

## CI/CD minima

Codex deve creare workflow GitHub Actions con questi step:
1. checkout
2. setup Python
3. install dependencies
4. lint
5. typecheck
6. test

No deploy automatico nella prima iterazione, ma struttura pronta per aggiungerlo.

---

## Documentation requirements

Codex deve generare documentazione minima ma utile:

### `README.md`
Deve contenere:
- scopo del progetto
- struttura repo
- stack
- quickstart locale
- variabili ambiente
- comandi principali

### `docs/architecture/overview.md`
Deve spiegare:
- layer architetturali
- flusso Streamlit/API -> application -> domain -> infrastructure
- motivazione della scelta modular monolith

### `docs/decisions/`
Creare almeno queste ADR iniziali:
- `001-use-streamlit-for-mvp.md`
- `002-modular-monolith-first.md`
- `003-api-first-even-with-streamlit.md`
- `004-llm-provider-abstraction.md`
- `005-supabase-for-initial-auth-and-data.md`

---

## Flussi da supportare nella prima iterazione

Codex deve costruire la repo per supportare subito questi flussi:

### Flusso 1 — autenticazione
- utente si registra / autentica
- sessione valida
- accesso alle schermate protette

### Flusso 2 — profilo pet
- creazione pet profile
- modifica pet profile
- recupero profilo esistente

### Flusso 3 — chat base
- utente invia domanda
- application layer costruisce richiesta contestuale
- adapter LLM risponde
- conversazione viene salvata

### Flusso 4 — reminder base
- creazione reminder semplice
- elenco reminder
- struttura pronta per scheduler futuro

---

## Confini chiari del primo ciclo

Codex **non deve** implementare da subito:
- marketplace veterinari
- assicurazioni
- calendari professionali
- image analysis
- billing complesso
- piani multi-tenant avanzati
- microservizi
- event bus distribuiti
- CQRS complicato
- Kubernetes

Può solo predisporre i punti di estensione.

---

## Convenzioni per estensioni future

Codex deve lasciare ganci puliti per:
- sostituzione Streamlit con Flutter client
- introduzione FastAPI come backend principale
- moduli documenti clinici / PDF
- retrieval da basi scientifiche
- reminder scheduler asincrono
- billing/subscription
- ruoli veterinario / utente finale / admin
- audit trail e observability avanzata

---

## Ordine di implementazione raccomandato

1. bootstrap repo e toolchain
2. config centralizzata
3. shared errors/types
4. core domain skeleton
5. application services e ports
6. infrastructure auth + persistence
7. infrastructure llm abstraction
8. api app minimale
9. streamlit client minimale
10. test + CI + docs

---

## Output atteso da Codex

Codex deve produrre:
- struttura cartelle completa
- file placeholder dove necessario
- setup toolchain funzionante
- dipendenze coerenti
- app Streamlit avviabile
- API avviabile
- layer core separato
- test di base eseguibili
- README e ADR iniziali

---

## Istruzione finale per Codex

Implementa la repository come **modular monolith Python, API-first, domain-oriented, con Streamlit come client temporaneo di validazione**.

La priorità assoluta non è massimizzare le feature, ma **massimizzare chiarezza strutturale, separazione dei layer e facilità di evoluzione**.

Ogni decisione va presa chiedendosi:
> “Questo ci aiuta a sostituire in futuro Streamlit con Flutter senza riscrivere il core?”

Se la risposta è no, la struttura va corretta.
