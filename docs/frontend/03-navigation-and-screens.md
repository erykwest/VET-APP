# 03 - Navigation and Screens

## Architettura di navigazione
Approccio consigliato:
- router dichiarativo
- shell principale con navigation rail / bottom navigation
- route guard per sessione autenticata
- route preview dedicata per founder demo

## Flusso iniziale
```text
Splash
  |- Onboarding
  |    \- Auth
  \- HomeShell
       |- Home
       |- Pets
       |- Chat
       \- Reminder

Web preview founder:
PreviewDashboard -> HomeShell
```

## Schermate minime

### Splash
Scopo:
- verifica sessione
- preload config
- redirect iniziale

Nota:
- in web preview senza Supabase attivo, il bootstrap puo instradare direttamente verso la preview dashboard

### Onboarding
Schermate:
- welcome
- value proposition
- privacy / disclaimer
- CTA a login o registrazione

### Auth
Schermate:
- login
- registrazione
- reset password

### Home
Blocchi:
- saluto utente
- pet attivo
- scorciatoie a profilo / chat / reminder
- card stato generale
- insight rapidi utili al racconto demo

### Pets
Schermate:
- lista pet
- crea pet
- dettaglio pet
- modifica pet

### Chat
Schermate:
- lista conversazioni
- dettaglio conversazione
- composer messaggio

### Reminders
Schermate:
- lista reminder
- crea reminder
- modifica reminder

### Profile
Schermate:
- profilo pet / utente collegato al percorso demo

### Estensioni fuori focus demo
Presenti nel repo ma non centrali per la preview founder:
- medical records
- settings

## Deep link futuri
- reminder specifico
- conversazione specifica
- invito a completare il profilo pet

## Regola UX
Ogni schermata deve esplicitare sempre:
- stato vuoto
- stato loading
- stato errore
- stato successo
