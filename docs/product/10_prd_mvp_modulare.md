**Product Requirements Document (PRD) \- App IA per Animali d'Affezione: Fase 1 (MVP Modulare)**

**1\. Obiettivo e Visione**L'obiettivo di questa prima fase è sviluppare un Prodotto Minimo Funzionante (MVP) basato su un ecosistema fortemente modulare 1, 2\. Lo scopo è testare rapidamente l'efficacia del sistema, avendo la flessibilità di sviluppare l'app un pezzo alla volta senza rompere le funzionalità esistenti man mano che verranno integrate 1, 2\. L'MVP getterà le basi per un assistente IA che fornisca ai proprietari di animali risposte affidabili basate su letteratura scientifica ad alto *impact factor* 3, 4\.

**2\. Target Audience dell'MVP**In questa fase pilota, l'app è destinata a test interni e a una ristretta cerchia di *early adopters* (proprietari di animali d'affezione) per validare il funzionamento tecnico dell'interazione con l'Intelligenza Artificiale prima di scalare verso funzionalità più complesse (es. veterinari o marketplace) 1, 5\.

**3\. Stack Tecnologico e Infrastruttura**Le fondamenta tecniche dell'MVP sono progettate per essere rapide da implementare, gratuite o a bassissimo costo, e pronte per futuri aggiornamenti 1, 5:

* **Gestione del Codice:** Inizializzazione di un ambiente su **GitHub** per il tracciamento e il versionamento del codice 1\.  
* **AI Coding Assistant:** Integrazione e utilizzo di **Antigravity** o **Codex** per accelerare la scrittura e la generazione dell'architettura dell'app 1\.  
* **Linguaggio e Frontend:** Sviluppo in **Python** con un'interfaccia utente essenziale basata su **Streamlit** 1\. Questo permette un deployment immediato della UI per validare l'interazione.  
* **Intelligenza Artificiale (LLM):** Per il prototipo verranno strutturate chiamate API verso un LLM di base e gratuito (come ad esempio **Groq**) 1, 5\. Questo permette di lavorare in un ambiente *free* per testare che il sistema funzioni prima di passare a modelli a pagamento 5\.  
* **Database e Backend:** Implementazione di **Supabase** per gestire l'autenticazione, la creazione dei profili utente e l'archiviazione sicura dei primissimi dati 1\.

  **4\. Requisiti Funzionali (Core Features)**

* **Sistema di Login/Registrazione:** L'app deve permettere all'utente di registrarsi in modo sicuro. Supabase gestirà la creazione degli account e l'autenticazione 1\.  
* **Interfaccia Chat (Streamlit):** Una singola pagina web essenziale in cui l'utente può inserire un prompt relativo al proprio animale e ricevere una risposta testuale generata dall'AI 1\.  
* **Inoltro e Gestione Chiamate API:** Il sistema deve essere in grado di impacchettare la richiesta dell'utente e inviarla correttamente alle API del LLM scelto (Groq), gestendo i tempi di risposta e visualizzando il testo a schermo 1, 6\.  
* **Architettura a Moduli:** Il codice alla base deve essere suddiviso in gruppi di istruzioni specifiche (es. modulo frontend, modulo database, modulo chiamate API), per preparare il terreno alle fasi successive senza dover riscrivere il software da zero 2\.

  **5\. Metriche di Successo (Milestones della Fase 1\)**

* Repository GitHub attivo e popolato tramite assistenza Codex/Antigravity 1\.  
* L'interfaccia Streamlit si avvia correttamente ed è accessibile via browser 1\.  
* Un utente può creare un account e loggarsi con successo (validazione Supabase) 1\.  
* L'utente inserisce una domanda di test sul proprio animale e riceve, in tempi congrui, una risposta coerente dal modello linguistico gratuito (validazione API LLM) 1, 5\.

  