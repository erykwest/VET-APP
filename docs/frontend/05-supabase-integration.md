# 05 - Supabase Integration

## Obiettivo
Integrare Supabase in modo pulito, evitando dipendenze sparse nell'interfaccia, senza renderlo un prerequisito obbligatorio della preview demo.

## Aree di integrazione
1. Auth
2. Database
3. Storage
4. Edge Functions / API proxy future
5. Realtime opzionale

## Modalita operative attuali

### 1. Preview demo-safe
- nessuna dipendenza obbligatoria da Supabase
- auth demo e seed locali
- utile per founder demo, UX review e smoke flow browser

### 2. Web auth reale con Supabase
- `SUPABASE_URL` e `SUPABASE_ANON_KEY` passati come Flutter `--dart-define`
- utile per validare login e sessione reali nella web app

### 3. Backend bootstrap Python
- il repo mantiene anche un backend FastAPI e una configurazione server-side separata dal frontend
- Supabase resta un adapter/runtime reale, non l'unico modo in cui il progetto puo essere avviato

## Regola architetturale
Il codice UI non parla direttamente con Supabase.
Passa sempre tramite:
- datasource
- repository
- service layer
- controller / state notifier

## Modelli principali iniziali

### users / profiles
Contenuti:
- id
- email
- display_name
- created_at
- onboarding_completed

### pets
Contenuti:
- id
- user_id
- name
- species
- breed
- birth_date
- sex
- weight
- notes
- created_at

### chat_threads
Contenuti:
- id
- user_id
- pet_id nullable
- title
- created_at
- updated_at

### chat_messages
Contenuti:
- id
- thread_id
- role
- content
- created_at

### reminders
Contenuti:
- id
- user_id
- pet_id
- type
- title
- due_date
- recurrence_rule nullable
- completed
- created_at

## Storage bucket iniziali
- `medical-records`
- `pet-assets` futuro

## Sicurezza
- Row Level Security obbligatoria
- ogni query filtrata per utente
- storage policy coerenti con ownership
- chiavi sensibili fuori dal client
- chiamate AI delicate instradate via backend/edge functions

## Environment variables minime
- SUPABASE_URL
- SUPABASE_ANON_KEY

Nota importante:
- nel client Flutter web queste variabili arrivano tramite `--dart-define`
- il file `.env` del repository non viene letto direttamente dal frontend Flutter

## Flusso consigliato per il frontend
```text
Page -> Controller/Notifier -> UseCase -> Repository -> Datasource -> Runtime
```

## Cosa NON fare
- query SQL o client Supabase direttamente dentro i widget
- mapping JSON dentro le pagine
- logica di autorizzazione sparsa nei componenti
