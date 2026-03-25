# 03 — Navigation and Screens

## Architettura di navigazione
Approccio consigliato:
- router dichiarativo
- shell principale con bottom navigation
- route guard per sessione autenticata

## Flusso iniziale
```text
Splash
 ├── Onboarding
 │    └── Auth
 └── HomeShell
      ├── Home
      ├── Pets
      ├── Chat
      ├── Records
      └── Settings
```

## Schermate minime

### Splash
Scopo:
- verifica sessione
- preload config
- redirect iniziale

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
- scorciatoie a chat / documenti / reminder
- card stato generale

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

### Medical Records
Schermate:
- lista documenti
- upload documento
- dettaglio metadati

### Reminders
Schermate:
- lista reminder
- crea reminder
- modifica reminder

### Settings / Profile
Schermate:
- profilo utente
- preferenze
- logout
- area tecnica/debug

## Deep link futuri
- apertura diretta di un documento
- reminder specifico
- conversazione specifica
- invito a completare il profilo pet

## Regola UX
Ogni schermata deve esplicitare sempre:
- stato vuoto
- stato loading
- stato errore
- stato successo
