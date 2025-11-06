---
title: Decibels Audio Player
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - audio
  - flatpack
---

## Introduzione

**Decibels** è un lettore audio moderno ed elegante per il desktop GNOME. È basato su una filosofia di semplicità, progettato per fare una cosa in modo eccezionale: riprodurre file audio.

A differenza delle applicazioni dedicate per la gestione delle librerie musicali come Rhythmbox, Decibels non gestisce una raccolta di brani musicali. Si concentra invece sull'offrire un'esperienza pulita e intuitiva per la riproduzione di singoli file audio. La sua caratteristica distintiva è una splendida visualizzazione della forma d'onda che consente una navigazione facile e precisa attraverso la traccia audio.

Questo la rende lo strumento perfetto per ascoltare rapidamente un podcast scaricato, un memo vocale o una nuova canzone senza dover importare i file in una libreria.

## Installazione

E' consigliato installare Decibels su Rocky Linux come Flatpak dal repository Flathub. Questo metodo garantisce di disporre della versione più recente dell'applicazione, ma isolata dal resto del sistema.

### 1. Abilitare Flathub

Per prima cosa, assicurati di avere Flatpak installato e Flathub Remote configurato sul sistema.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

!!! note "Nota"
Potrebbe essere necessario disconnettersi e riconnettersi affinché le applicazioni Flatpak appaiano nella panoramica delle attività di GNOME.

### 2. Installare Decibels

Una volta abilitato Flathub, puoi installare Decibels con un solo comando:

```bash
flatpak install flathub org.gnome.Decibels
```

## Utilizzo di Base

Dopo l'installazione, è possibile avviare Decibels dalla panoramica delle attività di GNOME cercando “Decibels”.

Riprodurre un file:

1. Eseguire l'applicazione. Verrai accolto da una finestra pulita e semplice.
2. Fai clic sul pulsante **"Open a File..."** situato al centro della finestra.
3. Utilizza il selettore di file per individuare e selezionare un file audio sul tuo sistema (ad esempio un file `.mp3`, `.flac`, `.ogg` o `.wav`).
4. Il file si aprirà e verrà visualizzata la sua forma d'onda. La riproduzione inizierà automaticamente.

## Caratteristiche Principali

Sebbene semplice, Decibels offre diverse funzioni utili:

- **Navigazione della forma d'onda:** invece di una semplice barra di avanzamento, Decibels mostra la forma d'onda dell'audio. È possibile cliccare in qualsiasi punto della forma d'onda per cercare istantaneamente quella parte della traccia.
- **Controllo della velocità di riproduzione:** un comando nell'angolo in basso a destra consente di regolare la velocità di riproduzione, ideale per accelerare i podcast o rallentare l'audio per la trascrizione.
- **Pulsanti di salto rapido:** pulsanti dedicati consentono di saltare indietro o avanti di 10 secondi alla volta, rendendo facile riascoltare una frase persa.

Decibels è una scelta eccellente per chiunque abbia bisogno di un'applicazione semplice, elegante e moderna per riprodurre singoli file audio sul desktop GNOME.
