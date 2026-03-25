# 05 — Supabase Integration

## Obiettivo
Integrare Supabase in modo pulito, evitando dipendenze sparse nell'interfaccia.

## Aree di integrazione
1. Auth
2. Database
3. Storage
4. Edge Functions / API proxy future
5. Realtime opzionale

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

### medical_records
Contenuti:
- id
- user_id
- pet_id
- file_path
- file_name
- mime_type
- category
- notes
- uploaded_at

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

## Flusso consigliato per il frontend
```text
Page -> Controller/Notifier -> UseCase -> Repository -> SupabaseDatasource
```

## Cosa NON fare
- query SQL o client Supabase direttamente dentro i widget
- mapping JSON dentro le pagine
- logica di autorizzazione sparsa nei componenti
