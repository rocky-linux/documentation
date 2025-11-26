---
title: Installazione di Rocky Linux 10 su AOOSTAR WTR PRO
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.0
tags:
  - hardware
---

## Introduzione

AOOSTAR WTR PRO è un NAS x86 a basso consumo con quattro alloggiamenti per unità. È un'alternativa più veloce ed economica all'HPE ProLiant MicroServer. Come esempio, l'autore ne ha acquistato uno come NAS personale.

Sebbene il WTR PRO sia progettato per eseguire distribuzioni Linux standard, il programma di installazione di Rocky Linux non si avvia immediatamente su questo dispositivo. Tuttavia, è comunque possibile installare Rocky Linux.

## Prerequisiti e presupposti

Di seguito sono riportati i requisiti minimi per l'utilizzo di questa procedura:

- Un programma di installazione Rocky Linux su USB

- Un dispositivo AOOSTAR WTR PRO

## Boot di installazione di Rocky Linux

Per prima cosa, si effettuerà il boot del sistema dalla USB.

Se sull'SSD è presente un sistema operativo esistente, premere il tasto `Canc` all'accensione del WTR PRO. Andare su **Salva ed esci** e seleziona l'USB.

Quando si fa il boot con l'USB nel menu GRUB, seleziona **Troubleshooting**:

![GRUB Main Menu](../images/aoostar_1.png)

Successivamente, selezionare **Install Rocky Linux _VERSION_ in basic graphics mode**:

![GRUB Troubleshooting Menu](../images/aoostar_2.png)

Rocky Linux dovrebbe ora avviarsi e installarsi normalmente.

Si noti che non è richiesta alcuna opzione speciale del kernel durante l'installazione di Rocky Linux.
