---
title: Rigenerare `initramfs`
author: Neel Chauhan
contributors: Spencer Steven
tested_with: 9.4
tags:
  - hardware
---

## Introduzione

Un \`initramfs' è il file system principale all'interno di un kernel Linux per aiutare l'avvio del sistema. Contiene i moduli fondamentali necessari per avviare Linux.

A volte, un amministratore Linux potrebbe voler rigenerare \`initramfs', ad esempio se vuole inserire un driver nella blacklist o includere un modulo out-of-band. L'autore ha fatto questo per [abilitare Intel vPro su un Minisforum MS-01](https://spaceterran.com/posts/step-by-step-guide-enabling-intel-vpro-on-your-minisforum-ms-01-bios/).

## Requisiti

A seguire i requisiti minimi per implementare questa procedura:

- Un sistema Rocky Linux o una macchina virtuale (non un container)
- Modifiche alla configurazione del kernel, come la creazione di una blacklist o l'aggiunta di un modulo

## Rigenerazione di `initramfs`

Per ricostituire l'`initramfs` si deve prima eseguire il backup dell'`initramfs` esistente:

```bash
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-$(date +%m-%d-%H%M%S).img
```

Quindi, eseguire `dracut` per rigenerare `initramfs`:

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

Quindi riavviare:

```bash
reboot
```

## Conclusione

Il kernel Linux è estremamente potente e modulare. È ragionevole che alcuni utenti vogliano consentire o meno alcuni moduli e la rigenerazione di `initramfs` permette di farlo.
