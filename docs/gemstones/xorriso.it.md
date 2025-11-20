---
title: Scrivere su CD/DVD fisici con Xorriso
author: Joseph Brinkman
---

## Introduzione

Recentemente ho scoperto che masterizzare ISO ibride su un CD/DVD fisico su Rocky Linux utilizzando strumenti grafici rappresenta una sfida. Fortunatamente, Xorriso è un'applicazione CLI semplice da usare che svolge egregiamente questo compito!

## Descrizione della problematica

Masterizza un ISO su un CD/DVD fisico.

## Prerequisiti

- Connessione internet
- Familiarità con il terminale
- Lettore RW CD/DVD

## Procedura

**Installare Xorriso**:

   ```bash
   sudo dnf install xorriso -y
   ```

**Scrivere la ISO su Disco**:

   ```bash
   sudo xorriso -as cdrecord -v dev/=/dev/sr0 -blank=as_needed -dao Rocky-10.1-x86_64-boot.iso
   ```

## Informazioni aggiuntive

Xorriso si basa su una libreria C libisofs. Per ulteriori informazioni su libisofs, consultare [Fedora's package watcher](https://packages.fedoraproject.org/pkgs/libisofs/libisofs/index.html).

## Conclusione

In questa gemstone hai imparato come scrivere un ISO su un disco fisico con Xorriso! Tenere presente che Xorriso può essere utilizzato per scrivere altri tipi di file su dischi fisici, ma è particolarmente utile per il formato ISO ibrido che gli strumenti grafici non sono in grado di gestire.
