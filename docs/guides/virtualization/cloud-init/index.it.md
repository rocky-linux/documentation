---
title: 0. cloud-init
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud-init
---

## Guida a cloud-init su Rocky Linux

Benvenuti nella guida completa a `cloud-init` su Rocky Linux. Questa serie vi guiderà dai concetti fondamentali dell'inizializzazione delle istanze cloud alle tecniche avanzate di provisioning e risoluzione dei problemi nel mondo reale. Che voi siate un nuovo utente che sta configurando il suo primo server cloud o un amministratore esperto che crea immagini personalizzate, questa guida fa al caso vostro.

I capitoli sono strutturati in modo da poter essere letti in ordine sequenziale, basandosi sulle conoscenze acquisite nelle sezioni precedenti.

---

## Capitoli in questa guida

**[1. Fondamentali](./01_fundamentals.md)**

> Scoprirete cos'è `cloud-init`, perché è essenziale per il cloud computing e quali sono le fasi del suo ciclo di vita esecutivo.

**[2. Primo contatto](./02_first_contact.md)**

> Il vostro primo esercizio pratico. Avviare un'immagine cloud ed eseguire una semplice personalizzazione utilizzando un file `user-data` di base.

**[3. Il motore di configurazione](./03_configuration_engine.md)**

> Approfondire il sistema del modulo `cloud-init`. Imparare a utilizzare i moduli più importanti per la gestione di utenti, pacchetti e file.

**[4. Provisioning avanzato](./04_advanced_provisioning.md)**

> Affrontare scenari complessi, tra cui come definire configurazioni di rete statiche e come combinare script e configurazioni cloud in un unico payload.

**[5. La prospettiva del image builder](./05_image_builders_perspective.md)**

> Cambiare la vostra prospettiva e assumere quella di un image builder. Scoprire come creare “golden images” con impostazioni predefinite integrate e come generalizzarle correttamente per la clonazione.

**[6. Troubleshooting](./06_troubleshooting.md)**

> Imparare l'arte essenziale della analisi forense di `cloud-init`. Comprendere i log, i comandi di stato e le insidie comuni per diagnosticare e risolvere i problemi in modo efficace.

**[7. Contribuire a cloud-init](./07_contributing.md)**

> Non limitartevi a essere un semplice utente. Questo capitolo fornisce una mappa per comprendere il codice sorgente di `cloud-init` e dare il vostro primo contributo al progetto open source.
