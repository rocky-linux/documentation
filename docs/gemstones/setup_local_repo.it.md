---
title: Impostazione dei repository Rocky locali
author: codedude
contributors: Steven Spencer, Franco Colussi
update: 09-dic-2021
---

# Introduzione

A volte è necessario disporre di repository Rocky in locale per creare macchine virtuali, ambienti di laboratorio e così via.  Può anche aiutare a risparmiare la larghezza di banda, se questo è un problema.  Questo articolo spiega come usare `rsync` per copiare i repository Rocky su un server web locale.  La costruzione di un server web non rientra nell'ambito di questo breve articolo.

## Requisiti

* Un server web

## Codice

```bash
#!/bin/bash
repos_base_dir="/web/path"

# Start sync if base repo directory exist
if [[ -d "$repos_base_dir" ]] ; then
  # Start Sync
  rsync  -avSHP --progress --delete --exclude-from=/opt/scripts/excludes.txt rsync://ord.mirror.rackspace.com/rocky  "$repos_base_dir" --delete-excluded
  # Download Rocky 8 repository key
  if [[ -e /web/path/RPM-GPG-KEY-rockyofficial ]]; then
     exit
  else
      wget -P $repos_base_dir https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
  fi
fi
```

## Ripartizione

Questo semplice script di shell utilizza `rsync` per prelevare i file del repository dal mirror più vicino.  Utilizza anche l'opzione "exclude", definita in un file di testo sotto forma di parole chiave che non devono essere incluse.  Le esclusioni sono utili se si dispone di spazio limitato su disco o se, per qualsiasi motivo, non si vuole tutto.  Possiamo usare `*` come carattere jolly.  Fate attenzione all'uso di `*/ng`, perché escluderà tutto ciò che corrisponde a questi caratteri.  Un esempio è riportato di seguito:

```bash
*/source*
*/debug*
*/images*
*/Devel*
8/*
8.4-RC1/*
8.4-RC1
```

## Fine

Un semplice script che può aiutare a risparmiare larghezza di banda o a semplificare la creazione di un ambiente di laboratorio.
