---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested with: 8.5
tags:
  - server
  - security
  - rkhunter
---

# Rootkit Hunter

## Prerequisiti

* Un Rocky Linux con in esecuzione un Web Server Apache
* Competenza con un editor a riga di comando (stiamo usando _vi_ in questo esempio)
* Un livello di comfort elevato con l'immissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* È utile una comprensione di ciò che può innescare una risposta ai file modificati sul file system (come gli aggiornamenti dei pacchetti)
* Tutti i comandi sono eseguiti come utente root o sudo

## Introduzione

_rkhunter_ (Root Kit Hunter) è uno strumento Unix-based che analizza i rootkit, backdoor e possibili exploit locali. È una buona parte per un server web rinforzato, ed è progettato per notificare rapidamente all'amministratore quando accade qualcosa di sospetto sul file system del server.

_rkhunter_ è solo un possibile componente di una configurazione rinforzata del server web Apache e può essere usato con o senza altri strumenti. Se si desidera utilizzare questo insieme ad altri strumenti per il rafforzamento, fare riferimento alla guida [Apache Web Server Rinforzato](index.md).

Il presente documento utilizza anche tutte le ipotesi e le convenzioni delineate in tale documento originale, quindi è una buona idea rivederlo prima di continuare.

## Installazione di rkhunter

_rkhunter_ richiede il repository EPEL (Extra Packages for Enterprise Linux). Quindi installa quel repository se non lo hai già installato:

`dnf install epel-release`

Quindi installa _rkhunter_:

`dnf install rkhunter`

## Configurazione di rkhunter

Le uniche opzioni di configurazione che devono essere impostate sono quelle che si occupano del mailing report all'amministratore. Per modificare il file di configurazione, esegui:

`vi /etc/rkhunter.conf`

E poi cerca:

`#MAIL-ON-WARNING=me@mydomain   root@mydomain`

Rimuovi il commento qui e cambia il me@mydomain.com per rispecchiare il tuo indirizzo email.

Quindi cambia root@mydomain in root@whatever_the_server_name_is.

Potrebbe anche essere necessario impostare [Email Postfix per la Segnalazione](../../email/postfix_reporting.md) per far funzionare correttamente la sezione e-mail.

## Eseguire rkhunter

_rkhunter_ può essere eseguito digitandolo alla riga di comando. C'è un cron job installato per te in `/etc/cron.daily`, ma se vuoi automatizzare la procedura su una programmazione diversa, guarda la guida [Automatizzare i lavori di cron](../../automation/cron_jobs_howto.md).

Avrai anche bisogno di spostare lo script da qualche parte diversa da `/etc/cron.daily`, come `/usr/local/sbin` e poi chiamarlo dal tuo cron job personalizzato. Il metodo più semplice, naturalmente, è quello di lasciare intatta la configurazione predefinita di cron.daily.

Prima di abilitare _rkhunter_ per l'esecuzione automatica, esegui il comando manualmente con la flag "--propupd" per creare il file rkhunter.dat, e per assicurarti che il tuo nuovo ambiente sia riconosciuto senza problemi:

`rkhunter --propupd`

Per eseguire _rkhunter_ manualmente:

`rkhunter --check`

Questo ritornerà sullo schermo man mano che vengono eseguiti i controlli, richiedendo di `[Press <ENTER> to continue]` dopo ogni sezione.

## Conclusione

_rkhunter_ è una parte di una strategia di rinforzo del server che può aiutare a monitorare il file system e a segnalare qualsiasi problema all'amministratore. È forse uno degli strumenti di rafforzamento più facili da installare, configurare ed eseguire.
