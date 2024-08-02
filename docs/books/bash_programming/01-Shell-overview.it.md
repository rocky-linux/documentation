---
title: Panoramica sulla shell
author: tianci li
contributors: Ganna Zhyrnova
tags:
  - Shell Introduction
---

# Introduzione di base

**Cos'è la Shell?**

Shell è chiamata **interfaccia di comando** o **interprete di comando**. Fornisce un programma di interfaccia a livello di sistema che consente agli utenti di inviare richieste al kernel Linux per l'esecuzione di programmi.

Nel presentare il sistema operativo, abbiamo citato la seguente frase:

> Intercetta l'**accesso alle periferiche**. Raramente il software può accedere direttamente all'hardware (ad eccezione delle schede grafiche per esigenze particolari).

![Shell01](./images/Shell01.png)

Il livello inferiore è costituito dai dispositivi hardware gestiti dal kernel Linux. Quando le persone si collegano in remoto al server tramite SSH e digitano vari comandi, il kernel Linux non riconosce queste parole o lettere. Come è noto, i computer sono in grado di riconoscere i linguaggi macchina, come 0 e 1. Per completare la conversione tra linguaggio umano e linguaggio macchina, è stato introdotto nel sistema operativo un agente di traduzione bidirezionale simile a quello della vita reale, ovvero Shell.

Funziona così:

**Persone del Paese A** <<--->> **Shell** <<--->> **Persone del Paese B**

Dal punto di vista dell'utente, Shell è un'interfaccia di interazione uomo-computer e le interfacce di interazione dei moderni sistemi operativi comprendono principalmente:

- Interfaccia di interazione a riga di comando. Ad esempio, sistemi operativi come **RockyLinux** e **Debian** svolgono ruoli di server.
- Interfaccia interattiva grafica. Ad esempio, il sistema operativo **Windows 11** per ambienti domestici e aziendali.
- Interfaccia interattiva mista a riga di comando e grafica. Ad esempio, **mint**, **Ubuntu** con ambiente grafico, **Windows Server** con Powershell, etc.

Classificazione delle shell:

- Bourne Shell - Questa famiglia incude, ma non si limita a:
  - sh (Bourne Shell, /usr/bin/sh). È stato sviluppato presso i Bell LABS nel 1977 da Stephen Bourne e utilizzato su V7 UNIX
  - ksh (Korn Shell, /usr/bin/ksh)
  - Bash (GNU Bourne-Again Shell, /bin/bash) - Nata nel 1987, è il prodotto del Progetto GNU. La maggior parte dei sistemi operativi GNU/Linux utilizza bash come shell predefinita
  - psh (POSIX Shell)
  - zsh (Z-shell)
- C Shell - Questa famiglia include, ma non si limita a:
  - csh
  - tcsh
- Power Shell
