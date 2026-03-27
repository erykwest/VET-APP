# Mobile Preview State

## Obiettivo
Tenere traccia dello stato reale della demo Flutter web in `apps/mobile_app`, con focus su preview Vercel, shell desktop-first e flussi demo navigabili.

## Stato attuale
La preview web di `apps/mobile_app` e pensata come esperienza `web-first` per founder demo e validazione prodotto.

Punti attivi:
- route preview pubblica senza dipendenza da login reale
- shell con sidebar persistente
- dashboard warm-clinical collegata ai seed demo
- chat demo interattiva
- records filtrabili per pet
- gestione pet con form piu strutturati e salvataggio demo locale

## Architettura demo

### Preview web
- la preview web usa una route dedicata `preview-dashboard`
- in ambiente web senza Supabase attivo, il bootstrap reindirizza la root verso la preview
- la preview mostra dati seed e un badge debug minimo

File chiave:
- [app.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/app/app.dart)
- [splash_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/app/splash/splash_page.dart)
- [app_router.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/app/router/app_router.dart)
- [preview_dashboard_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/app/preview/preview_dashboard_page.dart)

### Shell persistente
- la shell usa navigator per tab, non pagine isolate
- questo mantiene sidebar e navigation rail attive anche aprendo detail o create flow

File chiave:
- [home_shell_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/app/shell/home_shell_page.dart)

## Stato feature

### Home
- la dashboard non e piu blank nella preview
- il layout e stato reso piu robusto nel contenitore principale
- usa seed unificati per hero, reminders, AI, records e activity

File chiave:
- [home_dashboard_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/home/presentation/pages/home_dashboard_page.dart)
- [home_dashboard_seed_data.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/home/presentation/models/home_dashboard_seed_data.dart)

### Chat
- ora si puo avviare una nuova chat demo
- si possono inviare messaggi
- viene simulata una risposta dell assistente
- la lista conversazioni e il dettaglio leggono uno store condiviso demo

File chiave:
- [chat_demo_store.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/chat/data/chat_demo_store.dart)
- [chat_conversations_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/chat/presentation/pages/chat_conversations_page.dart)
- [chat_conversation_detail_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/chat/presentation/pages/chat_conversation_detail_page.dart)

### Medical Records
- la cartella clinica ha un layout piu resiliente
- e presente un filtro per pet
- i seed records includono piu profili animali

File chiave:
- [medical_records_repository.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/medical_records/data/medical_records_repository.dart)
- [medical_records_pages.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/medical_records/presentation/pages/medical_records_pages.dart)

### Pets
- create/edit usano campi obbligatori reali
- specie e un elenco obbligatorio
- razza dipende dalla specie ed e opzionale
- il peso e validato come numerico
- la data usa un date picker
- il salvataggio aggiorna davvero la lista demo

File chiave:
- [pet_demo_store.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/pets/data/pet_demo_store.dart)
- [pet_profile_form.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/pets/presentation/widgets/pet_profile_form.dart)
- [pets_list_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pets_list_page.dart)
- [pet_create_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pet_create_page.dart)
- [pet_edit_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pet_edit_page.dart)
- [pet_detail_page.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/lib/features/pets/presentation/pages/pet_detail_page.dart)

## Test e verifica

Verifiche usate durante questo ciclo:
- `flutter analyze` sui file integrati principali
- widget test preview per controllare il bootstrap della route demo

File test:
- [preview_dashboard_test.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/test/widget/preview_dashboard_test.dart)
- [widget_test.dart](/C:/Users/vasta/OneDrive%20-%20Techbau%20SpA/Documenti/PERS/VET%20APP/GIT/apps/mobile_app/test/widget_test.dart)

Nota importante:
- sull ambiente Windows locale, alcuni comandi Flutter emettono rumore finale legato a `puro` e sync cache/symlink
- quando `flutter analyze` ha gia riportato `No issues found`, quel rumore non va interpretato come errore del codice applicativo

## Debito ancora aperto
- consolidare la documentazione del design system warm-clinical in modo piu esplicito
- aggiungere test browser automatizzati sulla preview pubblica
- rimuovere o allineare i placeholder auth/onboarding rimasti fuori dal percorso preview
- valutare un piccolo store demo condiviso anche per home e records, non solo pets/chat
