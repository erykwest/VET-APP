# 12 - Backlog Tecnico Cartella Clinica

## Obiettivo
Tradurre la specifica di cartella clinica in backlog tecnico implementabile, ordinato per milestone, con separazione chiara tra database, backend, frontend, integrazioni e quality gates.

## Assunzioni operative
- stack confermato: Flutter web client, FastAPI backend, Supabase Auth/Postgres/Storage
- niente dipendenze che richiedano permessi di amministrazione
- il modulo si appoggia ai moduli esistenti `pets`, `medical_records`, `reminders` e `chat`
- l'MVP privilegia affidabilita del dato, semplicita UX e integrazione progressiva

## Definizione di done del modulo MVP
Il modulo e considerato pronto quando:
- un utente autenticato puo creare o aggiornare la scheda salute del pet
- puo caricare un documento clinico con metadata minimi obbligatori
- puo creare un evento clinico e ritrovarlo in timeline
- puo vedere reminder derivati da vaccini o trattamenti
- la chat riceve un context pack clinico sintetico e coerente
- tutte le superfici sensibili sono protette con RLS owner-based

## Dipendenze principali
- autenticazione utente stabile e owner resolution lato API
- persistenza Supabase gia operativa per `pets` e `reminders`
- bucket storage protetto per i file clinici
- contratti API chiari tra backend e Flutter

## Tassonomie minime da congelare prima dello sviluppo

### `document_type`
- `lab_result`
- `diagnostic_report`
- `prescription`
- `vaccination`
- `clinical_visit`
- `discharge`
- `image`
- `other`

### `event_type`
- `vaccination_administered`
- `parasite_treatment`
- `clinical_visit`
- `symptom_episode`
- `exam_result`
- `therapy_started`
- `therapy_updated`
- `therapy_ended`
- `emergency_visit`
- `note`

### `data_reliability_level`
- `user_reported`
- `document_uploaded`
- `auto_extracted`
- `user_verified`
- `vet_validated`

## Milestone 1 - Fondazione dati

### Obiettivo
Preparare schema, policy e storage per supportare il modulo senza ambiguita strutturali.

### Database
1. Creare migrazione per estensione tabella `pets` con campi clinici mancanti:
- `microchip_code`
- `neutered`
- `notes`

2. Creare tabella `pet_conditions`.

3. Creare tabella `pet_allergies`.

4. Creare tabella `pet_medications`.

5. Creare tabella `clinical_documents`.

6. Creare tabella `clinical_events`.

7. Creare tabella `vaccinations`.

8. Valutare se estendere tabella `reminders` esistente o aggiungere i campi mancanti:
- `pet_id`
- `source_event_id`
- `status`
- `reminder_type`

9. Aggiungere colonne comuni dove utili:
- `created_at`
- `updated_at`
- `created_by`

10. Aggiungere indici minimi:
- `clinical_events(pet_id, event_date desc)`
- `clinical_documents(pet_id, document_date desc)`
- `vaccinations(pet_id, due_date desc)`
- `pet_medications(pet_id, active)`

### Sicurezza
11. Applicare RLS owner-based su tutte le tabelle cliniche.

12. Definire policy storage per bucket documenti clinici con accesso limitato all'owner del pet.

13. Definire naming convention storage:
- `users/{user_id}/pets/{pet_id}/clinical/{document_id}/{filename}`

### Seed e test dati
14. Preparare seed minimo con:
- 1 owner demo
- 1 cane con storia clinica base
- 1 gatto con almeno un'allergia
- 3 documenti demo
- 5 eventi demo
- 2 reminder derivati

### Acceptance criteria
- migrazioni ripetibili senza interventi manuali
- query cronologiche su eventi e documenti supportate da indice
- nessun utente puo leggere dati clinici di un altro utente

## Milestone 2 - API e dominio clinico

### Obiettivo
Esporre CRUD e query aggregate per cartella clinica, documenti e timeline.

### Backend domain/application
15. Introdurre entita o DTO per:
- clinical document
- clinical event
- allergy
- condition
- medication
- vaccination
- clinical timeline item

16. Definire repository interfaces nel layer applicativo.

17. Implementare adapter Supabase/Postgres per i repository clinici.

18. Definire servizio `ClinicalRecordService` per orchestrare CRUD e regole base.

19. Definire servizio `ClinicalTimelineService` per aggregare:
- eventi
- documenti rilevanti
- terapie attive
- reminder imminenti

### API routes
20. Aggiungere endpoint:
- `GET /pets/{pet_id}/health-profile`
- `PATCH /pets/{pet_id}/health-profile`
- `GET /pets/{pet_id}/clinical-events`
- `POST /pets/{pet_id}/clinical-events`
- `PATCH /clinical-events/{event_id}`
- `DELETE /clinical-events/{event_id}`
- `GET /pets/{pet_id}/clinical-documents`
- `POST /pets/{pet_id}/clinical-documents`
- `PATCH /clinical-documents/{document_id}`
- `DELETE /clinical-documents/{document_id}`
- `GET /pets/{pet_id}/timeline`

21. Separare chiaramente upload fisico file da salvataggio metadata:
- opzione A: endpoint signed upload + conferma metadata
- opzione B: upload mediato dal backend se gia coerente con stack corrente

22. Aggiungere endpoint CRUD per:
- allergie
- patologie
- farmaci
- vaccinazioni

### Validation rules
23. Rendere obbligatori su documento:
- `document_type`
- `document_date`
- `title`

24. Rendere obbligatori su evento:
- `event_type`
- `event_date`
- `title`

25. Impedire collegamenti tra documenti ed eventi appartenenti a pet diversi.

### Acceptance criteria
- ogni endpoint rispetta ownership e validazioni
- la timeline restituisce un payload pronto per il frontend
- documenti ed eventi restano coerenti anche se creati in tempi diversi

## Milestone 3 - UI Flutter cartella clinica

### Obiettivo
Costruire la superficie minima utente per usare davvero il modulo.

### Routing e navigazione
26. Aggiungere entry point dalla schermata pet verso:
- dashboard cartella clinica
- timeline clinica
- documenti
- scheda salute

27. Valutare se introdurre sottoroute in `medical_records` o una feature dedicata `clinical_records`.

### Dashboard cartella clinica
28. Implementare schermata con:
- header pet
- alert attivi
- terapie correnti
- prossime scadenze
- CTA `Aggiungi evento`

29. Implementare stati:
- loading
- empty state
- error state

### Timeline clinica
30. Implementare lista cronologica unificata con card evento.

31. Aggiungere filtri minimi:
- tipo evento
- intervallo data

32. Mostrare per ogni item:
- data
- etichetta tipo
- titolo
- nota breve
- badge documento associato se presente

### Documenti
33. Implementare lista documenti con filtri:
- tipo
- data
- testo titolo

34. Implementare flow upload documento:
- selezione file
- form metadata
- conferma salvataggio

35. Mostrare stato verifica:
- caricato
- metadata completi
- verificato utente

### Scheda salute
36. Implementare sezioni editabili:
- dati clinici base
- allergie
- patologie
- farmaci
- vaccinazioni

37. Rendere semplice la creazione rapida di elementi con bottom sheet o dialog leggero.

### UX e copy
38. Uniformare microcopy a task semplici:
- `Carica referto`
- `Aggiungi terapia`
- `Segna come completato`
- `Vedi timeline`

### Acceptance criteria
- un utente puo completare i casi d'uso principali senza supporto
- ogni schermata esplicita loading, errore, vuoto e successo
- il flusso upload non richiede piu di un passaggio concettuale oltre alla scelta file

## Milestone 4 - Reminder automation

### Obiettivo
Derivare promemoria da dati clinici strutturati.

### Backend
39. Implementare regola reminder da `vaccinations.due_date`.

40. Implementare regola reminder da `pet_medications` quando e presente una frequenza interpretabile.

41. Introdurre funzione applicativa per generazione o aggiornamento reminder idempotente.

42. Salvare relazione tra reminder e origine:
- `source_event_id`
- oppure `source_entity_type` e `source_entity_id` se serve maggiore flessibilita

### Frontend
43. Mostrare nella dashboard clinica i reminder imminenti.

44. Aggiungere badge che distingua reminder manuale da reminder generato dalla cartella clinica.

45. Consentire stato:
- completato
- rinviato

### Acceptance criteria
- nessuna duplicazione incontrollata di reminder
- scadenze vaccinali sempre visibili nel profilo clinico
- l'utente capisce l'origine del reminder

## Milestone 5 - AI Clinical Context

### Obiettivo
Far consumare alla chat solo il contesto clinico rilevante e affidabile.

### Backend
46. Definire schema `ClinicalContextPack` con:
- pet summary
- allergies
- active_conditions
- active_medications
- recent_events
- recent_documents
- upcoming_reminders
- reliability_annotations

47. Implementare builder del context pack a partire da `pet_id`.

48. Limitare il pack a dati recenti e rilevanti:
- ultimi 3 eventi
- ultimi documenti rilevanti
- terapie attive soltanto

49. Distinguere nel payload:
- dato verificato
- dato non verificato
- dato autoestratto

50. Integrare il builder nella pipeline chat senza far leggere l'intero archivio.

### Prompting e guardrail
51. Aggiornare il prompt di sistema o orchestration layer per:
- citare quando una informazione proviene da dato non verificato
- evitare tono assertivo su campi autoestratti non confermati
- usare allergie e terapie attive come contesto prioritario

### Acceptance criteria
- la chat riceve payload sintetico e stabile
- l'uso del contesto clinico non introduce rumore superfluo
- le informazioni sensibili mantengono tracciabilita del livello di affidabilita

## Milestone 6 - Smart ingestion assistita

### Obiettivo
Aggiungere automazione utile senza perdere controllo sul dato.

### Backend
52. Salvare `extracted_text_summary` in `clinical_documents`.

53. Implementare pipeline asincrona o deferred per:
- OCR o text extraction
- classificazione suggerita del documento
- proposta metadata

54. Salvare suggerimenti separatamente dal dato verificato.

### Frontend
55. Mostrare i suggerimenti AI come bozza confermabile.

56. Consentire all'utente di:
- accettare
- modificare
- scartare

### Acceptance criteria
- nessun dato suggerito viene promosso a verificato senza azione utente
- i suggerimenti riducono il tempo di compilazione, non aumentano la complessita

## Backlog per stream tecnico

### Database e Supabase
- migrazioni schema clinico
- indici
- policy RLS
- bucket storage
- seed demo

### Backend Python
- modelli e schema API
- repository
- servizi timeline e context pack
- validazioni ownership
- reminder automation

### Frontend Flutter
- route e schermate
- form e liste
- upload UX
- gestione stati
- connessione ai repository o client API

### QA e test
- test policy RLS
- test CRUD API
- test timeline aggregation
- test reminder generation
- test widget e integration flow per upload/timeline

## Test plan minimo

### Backend
57. Testare che un utente non possa leggere o modificare dati di un pet non suo.

58. Testare creazione evento con documento valido.

59. Testare rifiuto collegamento evento-documento cross-pet.

60. Testare timeline ordinata per data con mix di eventi e vaccinazioni.

61. Testare generazione reminder idempotente.

62. Testare builder del context pack con livelli di affidabilita.

### Frontend
63. Test widget per:
- dashboard cartella clinica
- timeline filtrabile
- form upload documento
- scheda salute

64. Test integration per:
- carica documento
- crea evento
- visualizza timeline
- aggiorna terapia

## Sequenza consigliata di esecuzione
1. milestone 1 database e sicurezza
2. milestone 2 API e dominio
3. milestone 3 UI Flutter
4. milestone 4 reminder automation
5. milestone 5 AI clinical context
6. milestone 6 smart ingestion assistita

## Ticket candidati per il primo sprint
- creare migrazioni tabelle cliniche e policy RLS
- aggiungere bucket storage documenti clinici
- implementare endpoint health profile e clinical documents
- implementare schermata lista documenti e upload base
- implementare timeline read-only iniziale

## Ticket candidati per il secondo sprint
- CRUD eventi clinici
- CRUD allergie, patologie, farmaci, vaccinazioni
- dashboard cartella clinica
- reminder derivati da vaccinazioni
- seed demo con storia clinica completa

## Ticket candidati per il terzo sprint
- context pack per chat
- aggiornamento orchestrazione prompt
- reminder da terapie
- filtri timeline e documenti
- primi suggerimenti AI sui metadata

## Nota di priorita
Se serve comprimere ulteriormente il rilascio, l'ordine da preservare e:
1. health profile
2. document upload con metadata
3. timeline read-only
4. reminder vaccini
5. context pack chat

Tutto il resto puo slittare senza compromettere il valore principale del modulo.
