---
title: GNOME Shell Estensione
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - desktop
  - gnome
---

## Introduzione

Dal [sito web di GNOME](https://extensions.gnome.org/about/){:target="_blank"}:

> GNOME Shell fornisce le funzioni fondamentali dell'interfaccia utente di GNOME, come il passaggio alle finestre e l'avvio delle applicazioni. Gli elementi dell'interfaccia utente forniti da GNOME Shell includono il Pannello nella parte superiore dello schermo, la Panoramica delle attività e il Vassoio dei messaggi nella parte inferiore dello schermo."
> Le estensioni di GNOME Shell sono piccoli pezzi di codice scritti da sviluppatori di terze parti che modificano il funzionamento di GNOME. (Se avete familiarità con le estensioni di Chrome o i componenti aggiuntivi di Firefox, le estensioni di GNOME Shell sono simili a queste.) È possibile trovare e installare le estensioni di GNOME Shell utilizzando questo sito web.
> Le estensioni sono create al di fuori del normale processo di progettazione e sviluppo di GNOME e sono supportate dai loro autori, piuttosto che dalla comunità di GNOME. Alcune caratteristiche implementate per la prima volta come estensioni potrebbero trovare spazio nelle future versioni di GNOME.

## Presupposti

- Una workstation o un server Rocky Linux con installazione dell'interfaccia grafica che utilizza GNOME.

## Installare le estensioni GNOME

Le estensioni di GNOME sono fornite dal pacchetto gnome-shell nel repository "appstream". Installare con:

```bash
sudo dnf install gnome-shell
```

L'installazione include tutte le dipendenze necessarie.

## Installare l'integrazione del browser

Gnome Extensions ha una libreria di software disponibile attraverso il suo sito web, gnome.extensions.org, dove è possibile installare le estensioni direttamente dal sito. A tal fine, il browser e le estensioni di Gnome devono facilitare la connessione.

```bash
sudo dnf install chrome-gnome-shell
```

[installation guide](https://gnome.pages.gitlab.gnome.org/gnome-browser-integration/pages/installation-guide.html){target="_blank"}

## Determinare la versione della shell GNOME

L'estensione del browser utilizzata per facilitare l'installazione delle estensioni da extensions.gnome.org dovrebbe rilevare automaticamente la versione della shell GNOME attualmente in uso nel sistema.

Per eseguire un'installazione locale, è necessario scaricare l'estensione utilizzando la versione corretta della shell GNOME.

```bash
gnome-shell --version
```

## Installazione di un'estensione

Per questo esempio, installeremo la famosa estensione dash-to-dock.

1. Andate a [pagina web dell'estensione del dock](https://extensions.gnome.org/extension/307/dash-to-dock/){target="_blank"}
2. Attivare l'estensione da "off" a "on" ![Attivare l'estensione](images/gnome_extensions_images/gnome-shell-extensions-toggle-btn.webp)
3. Quando viene richiesto di installare l'estensione, fare clic su "sì".

## Gestione delle estensioni installate

Le estensioni di GNOME sono installate e gestite su gnome.extensions.org.

Per gestire le estensioni di GNOME, andare prima su <https://extensions.gnome.org/local/>

![Manage GNOME extensions](images/gnome_extensions_images/gnome-shell-installed-extensions.webp)

In questa pagina si trova un elenco delle estensioni installate. È possibile attivare o disattivare ciascuno di questi elementi. È inoltre possibile configurare le impostazioni della shell facendo clic sul pulsante di attivazione di una delle due opzioni di menu disponibili: "Disattiva tutte le estensioni" o "Disattiva la convalida della versione".

## Conclusione

Le estensioni di GNOME sono un ottimo strumento per aggiungere funzionalità e personalizzare l'ambiente desktop GNOME.
