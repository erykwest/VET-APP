# Flutter Mobile Setup

## Obiettivo

Preparare il client Flutter in `apps/mobile_app` e permettere a Codex di lavorare sul frontend mobile con feedback rapido.

## Stato attuale

La repo contiene un bootstrap Flutter manuale in:

- `apps/mobile_app/`

Il codice non e' stato eseguito in questa sessione perche' `flutter` e `dart` non sono ancora disponibili nel `PATH`.

## Installazione su Windows

1. Scarica Flutter SDK dal sito ufficiale.
2. Estrai la cartella in un path stabile, per esempio:
   - `C:\dev\flutter`
3. Aggiungi al `PATH`:
   - `C:\dev\flutter\bin`
4. Apri un nuovo terminale e verifica:
   - `flutter --version`
   - `dart --version`
5. Installa Android Studio.
6. In Android Studio installa:
   - Android SDK
   - Android SDK Command-line Tools
   - Android Emulator
   - plugin Flutter
   - plugin Dart
7. Accetta le licenze:
   - `flutter doctor --android-licenses`
8. Controlla lo stato finale:
   - `flutter doctor`

## Primo avvio del progetto

Dal root della repo:

```powershell
cd apps/mobile_app
flutter pub get
flutter run
```

## Target API locale

Per l'emulatore Android il backend locale FastAPI si raggiunge di solito con:

- `http://10.0.2.2:8000`

Questo valore e' gia' presente in `apps/mobile_app/.env.example`.

## Come lavorare bene con Codex su Flutter

Quando Flutter e' installato, il flusso ideale e':

1. tu lanci `flutter run`
2. io modifico i file in `apps/mobile_app/lib/`
3. tu fai hot reload con `r`
4. se serve, io leggo errori e li correggo

## Comandi utili

```powershell
cd apps/mobile_app
flutter pub get
flutter analyze
flutter test
flutter run
```

## Prossimi step consigliati

1. installare Flutter e verificare `flutter doctor`
2. far partire `apps/mobile_app`
3. rifinire onboarding
4. implementare `auth`
5. collegare API e Supabase
