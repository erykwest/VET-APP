# 02 — Feature Modules

## Moduli iniziali dell'MVP

### 1. onboarding
Responsabilità:
- intro rapida al valore dell'app
- consenso privacy base
- scelta del percorso iniziale

Output principali:
- flag "onboarding completed"
- eventuale deep link verso auth o creazione primo pet

### 2. auth
Responsabilità:
- login
- registrazione
- recupero password
- gestione sessione

Dipendenze:
- Supabase Auth

### 3. home
Responsabilità:
- dashboard sintetica
- accesso rapido a pet, chat, documenti e reminder
- stato generale dell'utente

### 4. pets
Responsabilità:
- creazione / modifica profilo animale
- elenco pet
- dettaglio pet

Campi minimi:
- nome
- specie
- razza
- età / data di nascita
- sesso
- peso
- note cliniche essenziali

### 5. chat
Responsabilità:
- interfaccia conversazionale
- cronologia conversazioni
- stato loading / errore
- eventuale contesto pet attivo

Nota:
la logica LLM non deve vivere nel widget; il frontend invoca un servizio o endpoint astratto.

### 6. medical_records
Responsabilità:
- upload documenti
- elenco file clinici
- metadati documento
- download / preview futura

### 7. reminders
Responsabilità:
- scadenze vaccini
- trattamenti antiparassitari
- visite / note manuali

### 8. profile
Responsabilità:
- dati utente
- preferenze
- gestione account

### 9. settings
Responsabilità:
- tema
- lingua futura
- notifiche
- version info / debug menu

## Priorità di build
Ordine consigliato di implementazione:
1. app shell
2. auth
3. onboarding
4. pets
5. home
6. chat
7. medical_records
8. reminders
9. profile / settings

## Regola di dipendenza
Una feature:
- può usare `core`, `design_system`, `shared`
- non dovrebbe leggere direttamente i file interni di un'altra feature
- comunica tramite repository, entity condivise o contratti espliciti
