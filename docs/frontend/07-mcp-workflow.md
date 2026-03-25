# 07 — MCP Workflow

## Obiettivo
Usare MCP come acceleratore reale del ciclo design -> codice -> backend.

## Stack MCP consigliato
- Figma MCP
- Flutter/Dart MCP
- Supabase MCP

## Workflow operativo

### Fase 1 — Design definition
Input:
- flussi
- schermate
- componenti
- token

Output:
- specifica UI chiara
- naming coerente
- mappa schermate

### Fase 2 — Flutter implementation
Input:
- componenti Figma
- regole di navigazione
- contratti dei moduli

Output:
- widget riutilizzabili
- pagine
- router
- controller

### Fase 3 — Supabase wiring
Input:
- modelli dati
- flow auth
- storage e policies

Output:
- datasource
- repository
- modelli serializzabili
- integrazione reale con backend

## Regole per lavorare bene con AI
- un prompt = un obiettivo chiaro
- chiedere prima struttura, poi implementazione
- evitare prompt che mescolano UI, backend e bugfix nello stesso task
- mantenere documentazione aggiornata e referenziabile

## Sequenza consigliata dei task
1. definizione cartelle e naming
2. app shell
3. design system base
4. auth flow
5. profilo pet
6. home
7. chat
8. documenti
9. reminder
10. rifiniture e test

## Definizione di pronto
Un task è “pronto” quando contiene:
- obiettivo
- file coinvolti
- output atteso
- vincoli
- criteri di accettazione
