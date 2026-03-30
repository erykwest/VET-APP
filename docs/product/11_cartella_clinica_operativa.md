# 11 - Cartella Clinica Operativa

## Obiettivo del modulo
Costruire un modulo di cartella clinica che conservi lo storico sanitario del pet, lo renda portabile nel tempo e alimenti in modo controllato reminder, timeline e assistenza conversazionale.

Il modulo non deve nascere come gestionale veterinario completo. Per la v1 deve essere un sistema clinico leggero:
- archivio affidabile di documenti e dati essenziali
- timeline sanitaria leggibile
- campi strutturati minimi ad alto valore
- interoperabilita con reminder e chat

## Problema che risolve
- oggi il proprietario del pet disperde referti, vaccini e prescrizioni tra email, WhatsApp e carta
- quando cambia veterinario o deve ricostruire una terapia, perde contesto e tempo
- la chat senza memoria clinica fornisce risposte meno personalizzate e meno utili

## Outcome atteso per l'MVP
- ogni pet ha una scheda salute leggibile e aggiornata
- l'utente puo caricare e recuperare facilmente documenti clinici
- gli eventi sanitari sono ricostruibili in ordine cronologico
- reminder e chat consumano solo il contesto clinico rilevante

## Principi guida
1. partire da un archivio affidabile prima di spingere l'automazione
2. distinguere chiaramente dato utente, documento, dato estratto e dato verificato
3. rendere il modulo semplice per il proprietario, non tecnico
4. mantenere l'utente proprietario del dato e capace di esportarlo
5. trattare l'AI come assistente di compilazione, non come fonte unica di verita

## Scope MVP

### In scope
- anagrafica pet estesa con dati clinici essenziali
- upload PDF e immagini su storage protetto
- metadata obbligatori per ogni documento
- eventi clinici strutturati collegabili a documenti
- timeline clinica unica per pet
- dati minimi per allergie, patologie, terapie, vaccinazioni
- generazione reminder da vaccini e trattamenti
- context pack clinico per la chat

### Out of scope per la v1
- parser clinico completamente automatico e non supervisionato
- validazione veterinaria in piattaforma
- interoperabilita con software veterinari esterni
- grafici clinici avanzati
- multi-caregiver avanzato
- condivisione temporanea granulare con professionisti

## Epic di prodotto

### Epic 1 - Pet Health Profile
Come owner voglio salvare le informazioni sanitarie di base del pet per avere un quadro sempre disponibile e riutilizzabile.

Acceptance criteria:
- posso creare e aggiornare il profilo sanitario del pet
- posso registrare allergie, patologie e terapie croniche
- il profilo mostra dati clinici essenziali in modo leggibile

### Epic 2 - Clinical Documents
Come owner voglio caricare referti e prescrizioni per conservarli in un unico posto e recuperarli quando servono.

Acceptance criteria:
- posso caricare PDF o immagini
- ogni file richiede tipo documento, data documento e titolo
- il documento resta associato al pet corretto
- il file e protetto da accessi di altri utenti

### Epic 3 - Clinical Events Timeline
Come owner voglio vedere una timeline ordinata degli eventi sanitari per ricostruire rapidamente la storia clinica del pet.

Acceptance criteria:
- posso creare un evento con data, tipo, titolo e nota breve
- un evento puo avere un documento allegato opzionale
- la timeline mostra eventi recenti, terapie attive e prossime scadenze
- la lista e filtrabile almeno per tipo evento e data

### Epic 4 - Reminder Linker
Come owner voglio che vaccini e trattamenti generino promemoria per non dimenticare scadenze importanti.

Acceptance criteria:
- un vaccino puo generare una prossima scadenza
- un trattamento puo creare reminder periodici o puntuali
- posso vedere stato reminder: in scadenza, completato, rinviato

### Epic 5 - AI Clinical Context
Come utente voglio che la chat conosca il contesto clinico essenziale del mio pet senza leggere ogni volta l'intero archivio.

Acceptance criteria:
- la chat riceve un context pack sintetico e tracciabile
- il prompt distingue dati verificati da dati non verificati
- il sistema non usa automaticamente campi estratti senza conferma utente come verita clinica

## User stories prioritarie

### P0
- Come nuovo utente voglio inserire peso, allergie, patologie note e terapia cronica durante onboarding o dalla scheda pet.
- Come utente voglio caricare un referto in PDF e associarlo al pet con metadata minimi obbligatori.
- Come utente voglio aggiungere un evento clinico manuale senza dover compilare una scheda complessa.
- Come utente voglio aprire una timeline clinica e vedere ultima visita, ultimo vaccino, ultima terapia e prossima scadenza.
- Come utente voglio che la chat possa vedere allergie, patologie attive e ultime informazioni rilevanti del pet.

### P1
- Come utente voglio classificare meglio i documenti con tipi standardizzati.
- Come utente voglio collegare un documento esistente a un nuovo evento clinico.
- Come utente voglio visualizzare le terapie attive in evidenza sulla dashboard clinica.
- Come utente voglio esportare lo storico essenziale del pet per mostrarlo a un veterinario.

### P2
- Come utente voglio ricevere suggerimenti AI sui metadata del documento da confermare.
- Come utente voglio vedere trend su peso o parametri clinici nel tempo.
- Come utente voglio condividere temporaneamente la cartella clinica con un caregiver o veterinario.

## UX minima consigliata

### 1. Dashboard Cartella Clinica
- pet attivo
- alert attivi
- terapia corrente
- prossime scadenze
- CTA principale: aggiungi evento

### 2. Timeline Clinica
- lista cronologica con icone evento
- filtri per tipo evento e data
- accesso rapido al documento associato

### 3. Documenti
- lista o griglia documenti
- filtri per tipo, data e titolo
- stato metadata e verifica utente

### 4. Scheda Salute
- allergie
- patologie
- farmaci
- vaccinazioni
- peso e dati clinici base

## Data model di riferimento

### Tabella `pets`
- `id`
- `owner_user_id`
- `name`
- `species`
- `breed`
- `sex`
- `birth_date`
- `weight_kg`
- `microchip_code`
- `neutered`
- `notes`

### Tabella `pet_conditions`
- `id`
- `pet_id`
- `condition_name`
- `status`
- `diagnosed_at`
- `severity`
- `notes`

### Tabella `pet_allergies`
- `id`
- `pet_id`
- `allergen`
- `reaction`
- `notes`

### Tabella `pet_medications`
- `id`
- `pet_id`
- `medication_name`
- `dosage`
- `frequency`
- `start_date`
- `end_date`
- `prescribing_vet`
- `notes`
- `active`

### Tabella `clinical_events`
- `id`
- `pet_id`
- `event_type`
- `title`
- `event_date`
- `summary`
- `severity`
- `source`
- `created_by`
- `linked_document_id`

### Tabella `clinical_documents`
- `id`
- `pet_id`
- `file_path`
- `original_filename`
- `document_type`
- `document_date`
- `uploaded_by`
- `status`
- `extracted_text_summary`
- `verified_by_user`
- `created_at`

### Tabella `vaccinations`
- `id`
- `pet_id`
- `vaccine_name`
- `administration_date`
- `due_date`
- `batch_number`
- `vet_name`
- `notes`

### Tabella `reminders`
- `id`
- `pet_id`
- `reminder_type`
- `due_date`
- `source_event_id`
- `status`

### Tabella `vets_contacts`
- `id`
- `pet_id`
- `clinic_name`
- `vet_name`
- `email`
- `phone`
- `notes`

## Moduli funzionali

### 1. Pet Profile Module
Responsabile di anagrafica e stato clinico base.

### 2. Clinical Events Module
Responsabile della registrazione strutturata di visite, esami, episodi e terapie.

### 3. Document Storage Module
Responsabile di upload, storage, metadata, accesso e stato di verifica dei file.

### 4. Clinical Timeline Module
Responsabile della composizione cronologica di eventi, documenti e scadenze.

### 5. Reminder Linker
Responsabile della derivazione di reminder da vaccini, controlli e trattamenti.

### 6. AI Context Layer
Responsabile della produzione del context pack clinico per la chat e altri moduli intelligenti.

## Strategia documentale

### Fase MVP
- upload PDF e immagini
- salvataggio su Supabase Storage
- metadata manuali obbligatori: tipo documento, data documento, titolo
- nota libera opzionale dell'utente

### Fase successiva
- estrazione testo da PDF
- classificazione automatica assistita
- suggerimento di campi chiave da confermare

### Regola operativa
L'automazione puo proporre compilazioni e classificazioni, ma l'utente deve poter confermare i campi critici prima che vengano trattati come affidabili nella chat.

## Livelli di affidabilita del dato
- Livello 1: dato inserito dall'utente
- Livello 2: documento caricato
- Livello 3: campo estratto automaticamente
- Livello 4: campo verificato dall'utente
- Livello 5: campo validato da veterinario

Uso operativo:
- reminder e timeline possono usare livelli 1-4
- la chat deve distinguere esplicitamente il livello quando la confidenza conta
- eventuali suggerimenti clinici devono privilegiare livelli 2-5 rispetto a testo libero non verificato

## Context pack per la chat
Il chatbot non deve consumare l'intera cartella clinica a ogni richiesta. Deve ricevere un pacchetto sintetico con:
- specie, eta, peso
- patologie attive
- allergie
- terapia attiva
- ultimi 3 eventi clinici
- ultimi esami rilevanti
- reminder imminenti

Obiettivi:
- ridurre costo token
- diminuire rumore nel prompt
- aumentare controllabilita e tracciabilita del contesto

## Sicurezza e privacy
- Row Level Security owner-based su tutte le tabelle sensibili
- storage protetto e accesso scoped per utente e pet
- separazione netta dei dati tra account
- audit log per modifiche sensibili
- consenso esplicito per uso AI dei documenti
- export e cancellazione dati disponibili all'utente

## Dipendenze architetturali
- Supabase Auth per legame owner_user_id
- Supabase Postgres per dati strutturati
- Supabase Storage per referti e immagini
- API backend per orchestration, policy enforcement e context pack
- feature `medical_records`, `pets`, `reminders` e `chat` nel client Flutter

## Piano di implementazione per milestone

### Milestone 1 - Fondazione dati
Obiettivo:
- schema DB
- relazioni base
- RLS owner-based
- bucket storage documenti

Deliverable:
- migrazioni tabelle principali
- policy di accesso
- upload documenti funzionante

### Milestone 2 - CRUD clinico
Obiettivo:
- CRUD per pet health profile, eventi, documenti, farmaci e allergie

Deliverable:
- UI base amministrabile
- API e repository dedicati
- timeline iniziale

### Milestone 3 - Reminder integration
Obiettivo:
- generare reminder da vaccini e trattamenti

Deliverable:
- reminder automatici
- dashboard scadenze
- stati completato e rinviato

### Milestone 4 - AI context integration
Obiettivo:
- collegare cartella clinica e chat tramite context pack

Deliverable:
- builder del context pack
- prompt integration con distinzione dei livelli di affidabilita
- risposte piu contestuali e meno rumorose

### Milestone 5 - Smart ingestion
Obiettivo:
- introdurre suggerimenti AI sui documenti senza perdere controllo utente

Deliverable:
- auto-tagging assistito
- precompilazione metadata
- conferma utente prima dell'uso come dato verificato

## KPI del modulo
- percentuale utenti che completano la scheda salute del pet
- numero medio di documenti caricati per pet
- percentuale documenti con metadata completi
- frequenza di ritorno alla timeline clinica
- numero di reminder generati dalla cartella clinica
- miglioramento percepito della qualita della chat grazie al contesto
- tempo medio per recuperare una informazione sanitaria importante

## Rischi principali e mitigazioni

### Rischio 1 - Scope eccessivo
Mitigazione:
- limitare la v1 ad archivio, timeline, campi minimi e reminder

### Rischio 2 - Estrazione automatica poco affidabile
Mitigazione:
- mantenere human-in-the-loop per metadata e campi clinici critici

### Rischio 3 - Dati disordinati
Mitigazione:
- definire una tassonomia semplice ma rigida per `event_type` e `document_type`

### Rischio 4 - UX troppo tecnica
Mitigazione:
- mantenere task e microcopy orientati ad azioni semplici: carica referto, aggiungi terapia, vedi scadenze

## Raccomandazione finale
Ordine netto di sviluppo:
1. archivio affidabile
2. timeline leggibile
3. campi clinici minimi
4. reminder automatici
5. uso intelligente nella chat
6. solo dopo estrazione AI piu spinta

Questa sequenza mantiene il modulo coerente con il PRD modulare, riduce il rischio di overbuilding e massimizza il valore percepito dall'utente gia' nella v1.
