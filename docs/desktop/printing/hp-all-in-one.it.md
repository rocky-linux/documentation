---
title: Installazione e configurazione HP All-in-One
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - desktop
  - printer support
---

## Introduzione

Stampare e scansionare con una stampante HP all-in-one sono possibili su Linux grazie a [HPLIP](https://developers.hp.com/hp-linux-imaging-and-printing/about){target=“_blank”}.

Questa guida è stata testata con una stampante HP Deskjet 2700.

Vedere [Tutte le stampanti supportate](https://developers.hp.com/hp-linux-imaging-and-printing/supported_devices/index){target=“_blank”} per verificare se il pacchetto HPLIP supporta la propria stampante.

## Scaricare e installare HPLIP

HPLIP è un software di terze parti di HP che contiene i driver di stampa necessari. Installate i seguenti 3 pacchetti per ottenere un supporto completo con un'interfaccia grafica.

```bash
sudo dnf install hplip-common.x86_64 hplip-libs.x86_64 hplip-gui
```

## Configurazione Stampante

Una volta terminata l'installazione del driver di stampa, è possibile aggiungere la stampante HP all-in-one alla workstation Rocky. Assicurarsi che la stampante sia fisicamente connessa alla stessa rete tramite Wi-Fi o connessione diretta. Vai alle impostazioni `Settings`.

1. Nel menu a sinistra, cliccare ++"Stampanti"++

2. Cliccare su ++"Add a Printer"++ (aggiungere stampante)

3. Selezionare la vostra stampante HP all-in-one

## Supporto per scanner

Il pacchetto HPLIP consente di eseguire la scansione utilizzando i comandi CLI, ma non fornisce un'applicazione per la scansione. Installare XSane, una applicazione di scansione facile da usare.

```bash
sudo dnf install sane-backends sane-frontends xsane
```

L'interfaccia grafica di XSane può apparire intimidatoria, ma una semplice scansione è facile. All'avvio di XSane è presente una finestra con un pulsante ++"Acquire a preview"++ che consente di acquisire un'anteprima. Questa operazione consente di acquisire un'immagine di anteprima di una scansione. Una volta pronta la scansione, fare clic su “Avvia” nel menu principale.

Per una guida più completa di XSane, leggere questo [articolo della Facoltà di Matematica dell'Università di Cambridge](https://www.maths.cam.ac.uk/computing/printing/xsane){target=“_blank”}

## Conclusione

Dopo aver installato HPLIP e XSane, dovreste essere in grado di stampare e scansionare la vostra stampante HP all-in-one .
