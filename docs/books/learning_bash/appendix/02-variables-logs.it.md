---
title: Variabili - Utilizzo Con I Registri
author: Steven Spencer
contributors: Antoine Le Morvan, Ganna Zhyrnova
tested_with: 8.5
tags:
  - bash scripting
  - bash
  - variables example
---

# Usare Le Variabili - Un'Applicazione Pratica Con I Registri

## Introduzione

Nella lezione due, "Bash - Utilizzando le variabili", hai visto alcuni modi per usare le variabili e hai imparato molto su come le variabili possono essere utilizzate. Questo è solo un esempio pratico di utilizzo di variabili all'interno dei tuoi script bash.

## Informazione

Quando un amministratore di sistema ha a che fare con i file di registro, ci sono a volte formati diversi che entrano in gioco. Diciamo che vuoi ottenere alcune informazioni dal `dnf.log` (`/var/log/dnf.log`). Diamo un'occhiata rapida a come sembra quel file di log usando `tail /var/log/dnf.log`:


```
2022-05-04T09:02:18-0400 DEBUG extras: using metadata from Thu 28 Apr 2022 04:25:35 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: powertools
2022-05-04T09:02:18-0400 DEBUG powertools: using metadata from Thu 28 Apr 2022 04:25:36 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel
2022-05-04T09:02:18-0400 DEBUG epel: using metadati from Tue 03 May 2022 11:55:16 AM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel-modular
2022-05-04T09:02:18-0400 DEBUG epel-modular: using metadata from Sun 17 Apr 2022 07:09:16 PM EDT.
2022-05-04T09:02:18-0400 INFO Last metadata expiration check: 3:07:06 ago on Wed 04 May 2022 05:55:12 AM EDT.
2022-05-04T09:02:18-0400 DDEBUG timer: sack setup: 512 ms
2022-05-04T09:02:18-0400 DDEBUG Cleaning up.
```

Ora dai un'occhiata al file di log `messages` in `tail /var/log/messages`:

```
May  4 08:47:19 localhost systemd[1]: Starting dnf makecache...
May  4 08:47:19 localhost dnf[108937]: Metadata cache refreshed recently.
4 maggio 08:47:19 localhost systemd[1]: dnf-makecache.service: Succeeded.
May  4 08:47:19 localhost systemd[1]: Started dnf makecache.
May  4 08:51:59 localhost NetworkManager[981]: <info>  [1651668719.5310] dhcp4 (eno1): state changed extended -> extended, address=192.168.1.141
May  4 08:51:59 localhost dbus-daemon[843]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.10' (uid=0 pid=981 comm="/usr/sbin/NetworkManager --no-daemon " label="system_u:system_r:NetworkManager_t:s0")
May  4 08:51:59 localhost systemd[1]: Starting Network Manager Script Dispatcher Service...
May  4 08:51:59 localhost dbus-daemon[843]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
May  4 08:51:59 localhost systemd[1]: Started Network Manager Script Dispatcher Service.
May  4 08:52:09 localhost systemd[1]: NetworkManager-dispatcher.service: Succeeded.
```

E finalmente diamo un'occhiata all'output del comando `date`:

```
Wed May  4 09:47:00 EDT 2022
```

## Risultati e obiettivi

Quello che possiamo vedere qui è che i due file di registro, `dnf.log` e `messages` visualizzano la data in modi completamente diversi. Se volevamo prendere le informazioni dai `messages` per accedere a uno script bash usando `date` potremmo farlo senza molti problemi, ma ottenere le stesse informazioni dal `dnf.log` richiederebbe un po di tempo. Diciamo che come amministratore di sistema, è necessario controllare il `dnf.log` ogni giorno per assicurarsi che nulla è stato introdotto nel sistema di cui non eravate a conoscenza o che potrebbe causare problemi. Vuoi che queste informazioni siano prese dal file `dnf.log` per data e poi inviate via email a te ogni giorno. Userai un lavoro `cron` per automatizzare questo, ma prima abbiamo bisogno di ottenere uno script che faccia quello che vogliamo.

## Script

Per realizzare ciò che vogliamo, useremo una variabile nella nostra script chiamata "today" che formatterà la data in base alla data visualizzata nel `dnf.log`.  Per ottenere il formato corretto `data` , stiamo usando il `+%F` che ci porterà il formato yyy-mm-dd che stiamo cercando. Dal momento che tutto ciò che ci interessa è il giorno, non i tempi o qualsiasi altra informazione, che è tutto quello che avremo bisogno per ottenere le informazioni corrette dal dnf `.log`. Prova solo questo gran parte dello script:

```
#!/usr/bin/env bash
# script per catturare i dati dnf.log e inviarli all'amministratore ogni giorno

today=`date +%F`
echo $today
```

Qui stiamo usando il comando `echo` per vedere se abbiamo avuto successo con la nostra formattazione della data. Quando si esegue lo script, si dovrebbe ottenere un output con la data di oggi che assomiglia a qualcosa di simile:

```
2022-05-04
```

Se così è allora grande, possiamo rimuovere la nostra linea "debug" e continuare. Aggiungiamo un'altra variabile chiamata "logfile" che imposteremo a `/var/log/dnf. og` e poi vediamo se possiamo `grep` che usando la nostra variabile "oggi". Per ora, lasciamo che sia eseguito su output standard:

```
!/usr/bin/env bash
# script to grab dnf. og data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile
```

Il `dnf. og` ha un sacco di informazioni in esso ogni giorno, quindi non stiamo pubblicando che sullo schermo qui, ma si dovrebbe vedere output che ha solo i dati di oggi in esso. Dare allo script una prova e se funziona, allora possiamo passare al passo successivo. Dopo aver controllato l'output, il passo successivo è che vogliamo effettuare un reindirizzamento del tubo per inviare le informazioni all'email.

!!! tip "Suggerimento"

    Hai bisogno di `mailx` e di un demone di posta come `postfix` installato per compiere questo passo successivo. C'è anche qualche configurazione che *probabilmente* sarà necessaria per ricevere email dal tuo server all'indirizzo email delle aziende. Non preoccuparti di quei passi a questo punto, perché puoi controllare il `maillog` per vedere se il tentativo è stato fatto e poi lavorare da lì per ottenere email dal tuo server al tuo indirizzo email funzionante. Non è qualcosa che questo documento si occuperà. Per ora fare:

    ```
    dnf install mailx postfix
    systemctl enable --now postfix
    ```

```
#!/usr/bin/env bash
# script per catturare i dati dnf.log e inviarli all'amministratore ogni giorno

today=`date +%F`
logfile=/var/log/dnf. og

/bin/grep $today $logfile <unk> /bin/mail -s "DNF logfile dati per $today" systemadministrator@domain.ext
```

Diamo un'occhiata alle aggiunte allo script qui. Abbiamo aggiunto una pipe `<unk>` per reindirizzare l'output a `/bin/mail` impostare l'oggetto dell'email (`-s`) con ciò che è in virgolette doppie e impostare il destinatario per essere "systemadministrator@domain. xt". Sostituisci l'ultimo bit con il tuo indirizzo email e riprova ad eseguire lo script.

Come notato, probabilmente non riceverai l'email senza alcune modifiche alla configurazione della posta Postfix, ma dovresti vedere il tentativo in `/var/log/maillog`.

## Prossimi Passi

La prossima cosa che devi fare è ottenere l'invio di e-mail dal funzionamento del server. Si può dare un'occhiata a [Postfix for Reporting](../../../guides/email/postfix_reporting.md) per iniziare. Abbiamo anche bisogno di automatizzare questo script per eseguire ogni giorno, per farlo useremo `cron`. Ci sono più riferimenti qui: [cron](../../../guides/automation/cron_jobs_howto.md), [anacron](../../../guides/automation/anacron.md), e [cronie](../../../guides/automation/cronie.md). Per ulteriori informazioni sulla formattazione della data, consulta `man date` o [questo link](https://man7.org/linux/man-pages/man1/date.1.html).
