# 00 — Project Overview

## Visione
Costruire un'app mobile che aiuti i proprietari di animali a gestire salute, profilazione, documenti clinici, reminder e interazione con un assistente IA.

## Obiettivi della base frontend
- definire un'architettura leggibile e scalabile
- evitare un monolite UI difficile da manutenere
- separare chiaramente:
  - presentazione
  - logica di dominio
  - accesso ai dati
  - integrazione con Supabase
  - integrazione futura con servizi AI

## Assunzioni architetturali
- **Frontend**: Flutter
- **Design source of truth**: Figma
- **Backend**: Supabase
- **Workflow assistito**: MCP + Codex
- **Approccio**: feature-first con convenzioni pulite

## Dominio iniziale dell'app
Le feature core da sostenere fin da subito sono:
1. account utente
2. gestione di uno o più pet
3. chat con assistente IA
4. upload e consultazione documenti clinici
5. reminder sanitari di base

## Requisiti non funzionali
- performance buona su dispositivi medi
- struttura semplice per onboarding di nuovi sviluppatori
- naming coerente
- testabilità di servizi e view model
- possibilità di introdurre versioni web/admin in futuro

## Decisioni chiave
- evitare cartelle per layer puramente tecnici e preferire moduli funzionali
- tenere il design system separato dalle feature
- usare adapter/repository per isolare Supabase dal resto dell'app
- tenere la logica AI lato backend o edge function quando possibile
