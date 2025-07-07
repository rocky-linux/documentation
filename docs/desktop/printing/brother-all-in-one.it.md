---
title: Installazione e configurazione per stampanti Brother All-in-One
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - desktop
  - printer support
---

## Introduzione

Stampare e scansionare con una stampante Brother all-in-one è possibile su Linux grazie ai driver per stampanti e scanner Brother all-in-one di terze parti.

!!! info "Informazione"

```
La procedura è stata testata con una Brother MFC-J480DW.
```

## Prerequisiti e presupposti

- Rocky 9.4 Workstation
- Privilegi `sudo`
- Stampante scanner Brother all-in-one

Questa guida presuppone che la stampante sia accessibile dalla workstation con una connessione diretta USB o LAN (Local Area Network). Il collegamento di una stampante alla LAN non rientra nell'intento di questo articolo.

## Aggiungere una stampante in GNOME

1. Aprire le ++"Impostazioni"++
2. Nel menu a sinistra, cliccare ++"Stampanti"++
3. Notate il banner sulla parte superiore della finestra che dice “Sblocca per modificare le impostazioni”
4. Cliccare su ++"Unlock"++ ed inserire le credenziali `sudo`.
5. Cliccare ++"Aggiungi"++

Dopo aver fatto clic su ++“Aggiungi ”++, ++“Impostazioni ”++ si avvierà la ricerca delle stampanti. Se la stampante non viene visualizzata, ma si conosce l'indirizzo IP della rete locale, inserire manualmente l'indirizzo IP. Il collegamento della stampante alla rete domestica non rientra negli scopi di questo articolo.

Si apre una finestra Software che tenta di individuare ed installare i driver della stampante. In genere, questa operazione fallisce. E' necessario visitare il sito web di Brother per installare i driver aggiuntivi.

## Scaricare e installare i drivers

[Istruzioni per l'installazione di Brother Driver Installer Script:](https://support.brother.com/g/b/downloadlist.aspx?&c=us&lang=en&prod=mfcj480dw_us_eu_as&os=127){target="_blank"}

1. [Scaricare lo script di bash per il driver della Brother MFC-J480DW](https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcj480dw_us_eu_as){target="_blank"}

2. Aprire la finestra del terminale.

3. Andare nella directory in cui è stato scaricato il file nell'ultimo passaggio. ad esempio, `cd Downloads`

4. Eseguire il comando per estrarre il file scaricato:

  ```bash
  gunzip linux-brprinter-installer-*.*.*-*.gz
  ```

5. Ottenere l'autorizzazione di superuser con il comando `su` o `sudo su`.

6. Eseguire il comando:

  ```bash
  bash linux-brprinter-installer-*.*.*-* Brother machine name
  ```

7. L'installazione del driver viene avviata. Seguire le istruzioni di installazione.

Il processo di installazione richiederà un po' di tempo. Attendere pazientemente il completamento. Una volta finito, è possibile inviare una stampa di test.

## Assistenza per Scanner

Xsane è una applicazione di scansione che fornisce un'interfaccia utente grafica per le scansioni. Utilizza i pacchetti disponibili nel repository appstream e non richiede alcuna configurazione aggiuntiva.

```bash
sudo dnf install sane-backends sane-frontends xsane
```

L'interfaccia grafica di Xsane può sembrare intimidatoria, ma eseguire una semplice scansione è immediato. Quando si avvia Xsane, viene visualizzata una finestra con un pulsante che consente di ++"Acquire a preview"++  (Acquisire un'anteprima). Questa operazione consente di ottenere una anteprima di una scansione. Una volta pronta la scansione, fare clic sul pulsante ++"Start"++ (avvia) dal menu principale.

Per una guida più completa su Xsane, leggere questo [articolo della Facoltà di Matematica dell'Università di Cambridge](https://www.maths.cam.ac.uk/computing/printing/xsane){target=“_blank”}.

## Conclusione

Dopo aver installato i driver Brother necessari e Xsane, si dovrebbe poter stampare e scansionare con la vostra Brother all-in-one.
