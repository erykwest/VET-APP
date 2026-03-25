# 06 — State Management and Data Flow

## Obiettivo
Rendere prevedibile il comportamento dell'app e semplice la manutenzione.

## Raccomandazione
Usare uno state management dichiarativo e testabile.
La scelta pratica può essere:
- Riverpod
oppure
- Bloc/Cubit

Per un progetto con forte supporto AI/Codex e molta modularità, Riverpod è spesso più lineare.

## Stati standard
Ogni feature dovrebbe avere stati espliciti:
- initial
- loading
- data
- empty
- error

## Pattern consigliato
```text
UI Widget
  -> controller / notifier
  -> use case
  -> repository
  -> datasource
  -> Supabase / API
```

## Caching minimo
- sessione utente in memoria
- pet attivo in memoria
- liste principali ricaricabili
- invalidazione esplicita dopo mutation

## Error handling
Standardizzare:
- network error
- auth error
- validation error
- unexpected error

## Logging
Prevedere un layer comune per:
- log di debug locale
- error reporting futuro
- tracing minimo di eventi chiave

## Loading UX
Mai bloccare l'intera app se non necessario.
Preferire:
- skeleton
- progress locale
- optimistic update solo dove sensato

## Contratti dei controller
Ogni controller dovrebbe esporre:
- stato corrente
- azioni utente principali
- dipendenze iniettate
- nessuna dipendenza diretta da widget specifici
