# Mobile Preview State

## Obiettivo
Tenere traccia dello stato reale della demo Flutter web in `apps/mobile_app`, con focus su preview founder, shell core-loop e flussi demo navigabili.

## Stato attuale
La preview web di `apps/mobile_app` e pensata come esperienza `web-first` per founder demo e validazione prodotto.

Punti attivi:
- route preview pubblica senza dipendenza da login reale
- shell con sidebar persistente
- shell core-loop con `Home`, `Pets`, `Chat` e `Reminder`
- dashboard warm-clinical collegata ai seed demo e a insight rapidi
- chat demo interattiva
- gestione pet con form strutturati e salvataggio demo locale
- reminder come quarto pilastro della preview founder

## Architettura demo

### Preview web
- la preview web usa una route dedicata `preview-dashboard`
- in ambiente web senza Supabase attivo, il bootstrap reindirizza la root verso la preview
- la preview mostra dati seed e un badge debug minimo

File chiave:
- [app.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/app/app.dart)
- [splash_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/app/splash/splash_page.dart)
- [app_router.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/app/router/app_router.dart)
- [preview_dashboard_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/app/preview/preview_dashboard_page.dart)

### Shell persistente
- la shell usa navigator per tab, non pagine isolate
- questo mantiene navigation rail e contesto attivi durante il percorso demo

File chiave:
- [home_shell_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/app/shell/home_shell_page.dart)

## Stato feature

### Home
- la dashboard non e piu blank nella preview
- il layout e stato reso piu robusto nel contenitore principale
- usa seed unificati per hero, reminders, AI e insight
- mette in primo piano profilo, chat e reminder

File chiave:
- [home_dashboard_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/home/presentation/pages/home_dashboard_page.dart)
- [home_dashboard_seed_data.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/home/presentation/models/home_dashboard_seed_data.dart)

### Chat
- si puo avviare una nuova chat demo
- si possono inviare messaggi
- viene simulata una risposta dell assistente
- lista conversazioni e dettaglio leggono uno store condiviso demo
- stati empty/loading/error sono stati resi piu robusti per layout stretti

File chiave:
- [chat_demo_store.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/chat/data/chat_demo_store.dart)
- [chat_conversations_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/chat/presentation/pages/chat_conversations_page.dart)
- [chat_conversation_detail_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/chat/presentation/pages/chat_conversation_detail_page.dart)

### Pets
- create/edit usano campi obbligatori reali
- specie e un elenco obbligatorio
- razza dipende dalla specie ed e opzionale
- il peso e validato come numerico
- la data usa un date picker
- il salvataggio aggiorna davvero la lista demo

File chiave:
- [pet_demo_store.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/pets/data/pet_demo_store.dart)
- [pet_profile_form.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/pets/presentation/widgets/pet_profile_form.dart)
- [pets_list_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pets_list_page.dart)
- [pet_create_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pet_create_page.dart)
- [pet_edit_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pet_edit_page.dart)
- [pet_detail_page.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pet_detail_page.dart)

### Reminder
- reminder esposto come quarto pilastro della shell demo
- lista, create, edit e detail sono navigabili nel percorso founder

File chiave:
- [reminders_pages.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/lib/features/reminders/presentation/pages/reminders_pages.dart)

## Test e verifica

Verifiche usate durante questo ciclo:
- test widget preview per controllare bootstrap e route demo
- test widget chat per controllare lista, empty state e detail

File test:
- [preview_dashboard_test.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/test/widget/preview_dashboard_test.dart)
- [widget_test.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/test/widget_test.dart)
- [chat_feature_test.dart](/C:/Users/vasta/.codex/worktrees/31bd/GIT/apps/mobile_app/test/chat/chat_feature_test.dart)

Nota importante:
- sull ambiente Windows locale, alcuni comandi Flutter possono emettere rumore finale legato a `puro` e sync cache/symlink
- quando la suite test passa prima di quei messaggi, quel rumore non va interpretato come errore del codice applicativo

## Debito ancora aperto
- consolidare la documentazione del design system warm-clinical in modo piu esplicito
- aggiungere test browser automatizzati sulla preview pubblica
- chiarire meglio il confine tra superfici demo-safe e flussi con Supabase reale
- decidere quanto del percorso auth/onboarding debba restare dentro o fuori la preview founder principale
