---
title: dnf - swap command
author: wale soyinka
contributors:
date: 2023-01-24
tags:
  - cloud images
  - containers
  - dnf
  - dnf swap
  - vim
  - vim-minimal
  - allowerasing
  - coreutils-single
---

# Introduzione

Per rendere le immagini dei container e di quelle cloud il più piccole possibile, i manutentori delle distribuzioni e i gestori dei pacchetti possono talvolta fornire versioni ridotte dei pacchetti più diffusi. Esempi di pacchetti ridotti al minimo forniti in bundle con immagini container o cloud sono **vim-minimal, curl-minimal, coreutils-single** e così via.

Anche se alcuni dei pacchetti forniti sono versioni ridotte, spesso sono del tutto accettabili per la maggior parte dei casi d'uso.

Nei casi in cui il pacchetto ridotto non sia sufficiente, è possibile utilizzare il comando `dnf swap` per sostituire rapidamente il pacchetto minimo con il pacchetto normale.

## Obiettivo

Questo Rocky Linux GEMstone mostra come utilizzare **dnf** per _swap_ (sostituire) il pacchetto `vim-minimal` in dotazione con il pacchetto `vim` standard.

## Controllare la variante di `vim` esistente

Dopo aver effettuato l'accesso al proprio ambiente container o macchina virtuale come utente con privilegi amministrativi, verificare innanzitutto la variante del pacchetto `vim` sia installata. Digita:

```bash
# rpm -qa | grep  ^vim
vim-minimal-8.2.2637-22.el9_6.1.x86_64
```

Il pacchetto `vim-minimal` è presente nel sistema.

## Sostituire `vim-minimal` con `vim`

Utilizza `dnf` per sostituire (swap) il pacchetto `vim-minimal` installato con il pacchetto `vim` standard.

```bash
# dnf -y swap vim-minimal vim
```

## Controllare la nuova variante del pacchetto `vim`

Per confermare le modifiche, interrogare nuovamente il database rpm per i pacchetti `vim` installati eseguendo:

```bash
# rpm -qa | grep  ^vim
vim-enhanced-8.2.2637-22.el9_6.1.x86_64
```

Ed è una GEMMA!

## Note

Comando DNF Swap

**Sintassi**:

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Sotto il cofano, `dnf swap` utilizza l'opzione `--allowerasing` di DNF per risolvere eventuali conflitti tra pacchetti. Pertanto, l'esempio di `vim` minimale mostrato in questa GEMstone avrebbe potuto essere eseguito anche eseguendo:

```bash
dnf install -y --allowerasing vim
```
