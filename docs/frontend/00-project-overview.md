# 00 - Project Overview

## Visione
Costruire un'app pet-tech web-first che aiuti i proprietari di animali a gestire profilo pet, reminder e interazione con un assistente IA, mantenendo una configurazione mobile-ready per release successive.

## Obiettivi della base frontend
- definire un'architettura leggibile e scalabile
- evitare un monolite UI difficile da manutenere
- separare chiaramente:
  - presentazione
  - logica di dominio
  - accesso ai dati
  - integrazione runtime
  - integrazione futura con servizi AI

## Assunzioni architetturali
- **Frontend**: Flutter
- **Design source of truth**: Figma
- **Backend demo/runtime**: FastAPI bootstrap + modalita preview locale
- **Auth e persistence reali**: Supabase quando attivato
- **Workflow assistito**: MCP + Codex
- **Approccio**: feature-first con convenzioni pulite

## Dominio iniziale dell'app
Le feature core da sostenere fin da subito sono:
1. account utente
2. gestione di uno o piu pet
3. chat con assistente IA
4. reminder sanitari di base

Per la preview web attuale, il racconto principale e centrato sul core loop:
- onboarding
- auth
- home dashboard
- pet profile
- chat
- reminder

Le superfici `medical_records`, `settings` e altre estensioni restano nel repo ma non definiscono il perimetro della demo founder.

## Requisiti non funzionali
- performance buona su dispositivi medi
- struttura semplice per onboarding di nuovi sviluppatori
- naming coerente
- testabilita di servizi e view model
- possibilita di introdurre versioni web/admin in futuro

## Decisioni chiave
- evitare cartelle per layer puramente tecnici e preferire moduli funzionali
- tenere il design system separato dalle feature
- usare adapter/repository per isolare runtime demo, API e Supabase dal resto dell'app
- tenere la logica AI lato backend o edge function quando possibile
