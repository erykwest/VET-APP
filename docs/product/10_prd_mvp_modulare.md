# PRD MVP Modulare

## 1. Obiettivo e visione
Costruire una demo web credibile e coerente, capace di mostrare il loop principale del prodotto senza pretendere di coprire tutta la roadmap. Il sistema deve dare subito l'idea di un prodotto gia' vivo: onboarding, login, home, pet profile, chat, records e reminder.

## 2. Target audience
La prima iterazione e' pensata per test interni e per una piccola cerchia di early adopter, con focus sulla chiarezza del valore percepito e sulla leggibilita' del flusso web, con mobile-ready configuration per release successive.

## 3. Stack tecnologico
- Flutter web come client principale
- Python come backend e layer di orchestrazione
- Supabase per autenticazione e persistenza
- LLM provider astratto e configurabile

## 4. Requisiti funzionali core
- login e registrazione
- home dashboard con pet attivo e prossima scadenza
- pet profile coerente e leggibile
- chat assistita con thread demo credibile
- records e reminder con almeno un elemento mostrabile

## 5. Metriche di successo
- demo web Flutter navigabile end-to-end
- coerenza linguistica e visiva tra tutte le schermate principali
- almeno un pet principale, un reminder imminente e un record clinico mostrabile
- messaggio chiaro sul confine tra preview web e integrazioni backend reali
