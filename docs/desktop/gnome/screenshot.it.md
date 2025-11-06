---
title: Acquisizione di schermate e registrazione di screencast in GNOME
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - screenshot
  - screencast
  - guide
---

## Introduzione

Il moderno desktop GNOME, presente in Rocky Linux, include uno strumento potente e perfettamente integrato per catturare lo schermo. Non si tratta di un'applicazione separata da installare, ma di una parte fondamentale della shell del desktop, che offre un modo fluido ed efficiente per acquisire schermate e registrare brevi video (screencast).

Questa guida illustra come utilizzare sia l'interfaccia utente interattiva che le potenti scorciatoie da tastiera per acquisire il contenuto dello schermo.

## Utilizzo dell'interfaccia utente interattiva per gli screenshot

Il modo più semplice per iniziare è con la sovrapposizione interattiva, che ti offre il controllo completo su ciò che catturi e su come lo catturi.

1. **Avvia lo strumento:** premi il tasto `Print Screen` (spesso indicato con `PrtSc`) sulla tastiera. Lo schermo si oscurerà e apparirà l'interfaccia utente dello screenshot.

2. **Comprendere l'interfaccia:** Il pannello di controllo al centro dello schermo presenta tre sezioni principali:
   - **Capture Mode:** A sinistra, si può scegliere di catturare una `Regione` rettangolare, l'intero `Schermo` o una `Finestra` specifica.
   - **Action Toggle:** Al centro è possibile passare dalla modalità **Screenshot** (icona della fotocamera) alla modalità **Screencast** (icona della videocamera) e viceversa.
   - **Capture Button:** Il grande pulsante rotondo sulla destra avvia l'acquisizione.

### Cattura la schermata

1. Assicurarsi che il pulsante di azione sia impostato su **Screenshot** (icona della fotocamera).
2. Selezionare la modalità di acquisizione: `Regione`, `Schermo` o `Finestra`.
3. Cliccare sul pulsante rotondo **Cattura**.

Per impostazione predefinita, l'immagine dello screenshot viene salvata automaticamente nella directory `Immagini/Screenshot` nella cartella home.

### Registrazione di uno Screencast

1. Imposta l'interruttore di azione su **Screencast** (l'icona della videocamera).
2. Seleziona l'area che desideri registrare (`Regione` o `Schermo`).
3. Fai clic sul pulsante rotondo **Cattura** per avviare la registrazione.

Un punto rosso apparirà nell'angolo in alto a destra dello schermo, insieme a un timer, a indicare che la registrazione è attiva. Per fermarla, cliccare il pulsante rosso. Il video verrà automaticamente salvato come file `.webm` nella directory `Videos/Screencasts` nella cartella home.

## Scorciatoie da tastiera per utenti esperti

Per acquisizioni ancora più veloci, GNOME fornisce una serie di scorciatoie da tastiera dirette che bypassano l'interfaccia utente interattiva.

| Scorciatoia            | Azione                                                                                        |
| ---------------------- | --------------------------------------------------------------------------------------------- |
| ++print-screen++       | Attiva l'interfaccia utente interattiva dello screenshot.                     |
| ++alt+print-screen++   | Cattura immediatamente uno screenshot della finestra attualmente attiva.      |
| ++shift+print-screen++ | Avvia immediatamente la selezione di un'area rettangolare per uno screenshot. |
| ++ctrl+alt+shift+"R"++ | Avvia e interrompe una registrazione a schermo intero.                        |

### Il modificatore “Copia negli appunti”

Si tratta di una potente funzione che migliora la produttività. Aggiungendo il tasto ++ctrl++ a una qualsiasi delle scorciatoie per gli screenshot, l'immagine catturata verrà copiata direttamente negli appunti invece di essere salvata in un file. È perfetto per incollare rapidamente uno screenshot in un'altra applicazione, come un documento o una finestra di chat.

- \++ctrl+print-screen++: Apre l'interfaccia utente interattiva, ma l'immagine acquisita verrà salvata negli appunti.
- \++ctrl+alt+print-screen++: Copia uno screenshot della finestra attiva negli appunti.
- \++ctrl+shift+print-screen++: Copia uno screenshot dell'area selezionata negli appunti.

Lo strumento integrato di GNOME per screenshot e screencast è un perfetto esempio di design elegante ed efficiente, che offre sia un'interfaccia semplice e intuitiva per i nuovi utenti, sia un flusso di lavoro veloce e basato su scorciatoie per gli utenti esperti.
